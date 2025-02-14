pragma solidity ^0.4.24;































contract BMRoll is usingOraclize {
    using SafeMath for uint256;
    


    modifier betIsValid(uint _betSize, uint _playerNumber) {      
        require(_betSize >= minBet && _playerNumber >= minNumber && _playerNumber <= maxNumber && (((((_betSize * (100-(_playerNumber.sub(1)))) / (_playerNumber.sub(1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize <= maxProfit));
		_;
    }

    


    modifier gameIsActive {
        require(gamePaused == false);
		_;
    }    

    


    modifier payoutsAreActive {
        require(payoutsPaused == false);
		_;
    }    

    


    modifier onlyOraclize {
        require(msg.sender == oraclize_cbAddress());
        _;
    }

    


    modifier onlyOwner {
         require(msg.sender == owner);
         _;
    }

    


    modifier onlyTreasury {
         require (msg.sender == treasury);
         _;
    }    

    

 
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;    
    uint constant public maxNumber = 99; 
    uint constant public minNumber = 2;
	bool public gamePaused;
    uint32 public gasForOraclize;
    address public owner;
    bool public payoutsPaused; 
    address public treasury;
    uint public contractBalance;
    uint public houseEdge;     
    uint public maxProfit;   
    uint public maxProfitAsPercentOfHouse;                    
    uint public minBet; 

    uint public totalBets = 0;
    uint public totalWeiWon = 0;
    uint public totalWeiWagered = 0; 

    uint public maxPendingPayouts;
    
    


    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => address) playerTempAddress;
    mapping (bytes32 => bytes32) playerBetId;
    mapping (bytes32 => uint) playerBetValue;
    mapping (bytes32 => uint) playerTempBetValue;               
    mapping (bytes32 => uint) playerDieResult;
    mapping (bytes32 => uint) playerNumber;
    mapping (address => uint) playerPendingWithdrawals;      
    mapping (bytes32 => uint) playerProfit;
    mapping (bytes32 => uint) playerTempReward;           

    


    
    event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);      
    
    
	event LogResult(bytes32 indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint ProfitValue, uint BetValue, int Status, bytes Proof);   
    
    event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
    
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               


    


    constructor() public {

        owner = msg.sender;
        treasury = msg.sender;
        oraclize_setNetwork(networkID_auto);        
        
        oraclize_setProof(proofType_Ledger);
        
        ownerSetHouseEdge(980);
        
        ownerSetMaxProfitAsPercentOfHouse(50000);
        
        ownerSetMinBet(100000000000000000);        
                
        gasForOraclize = 235000;  
        
        oraclize_setCustomGasPrice(20000000000 wei);              

    }

    




    function playerRollDice(uint rollUnder) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollUnder)
	{       

        bytes32 rngId = oraclize_newRandomDSQuery(0, 1, gasForOraclize); 

        
		playerBetId[rngId] = rngId;
        
		playerNumber[rngId] = rollUnder;
        
        playerBetValue[rngId] = msg.value;
        
        playerAddress[rngId] = msg.sender;
                             
        playerProfit[rngId] = ((((msg.value * (100-(rollUnder.sub(1)))) / (rollUnder.sub(1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
        
        maxPendingPayouts = maxPendingPayouts.add(playerProfit[rngId]);
        
        if(maxPendingPayouts >= contractBalance) revert();
        
        emit LogBet(playerBetId[rngId], playerAddress[rngId], playerBetValue[rngId].add(playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);          

    }   
             

    


	function __callback(bytes32 myid, string result, bytes proof) public   
		onlyOraclize
		payoutsAreActive
	{  

        
        require(playerAddress[myid]!=0x0);

            
        
        playerDieResult[myid] = uint(keccak256(abi.encodePacked(result))) % 100; 
        
        playerTempAddress[myid] = playerAddress[myid];
        
        delete playerAddress[myid];

        
        playerTempReward[myid] = playerProfit[myid];
        
        playerProfit[myid] = 0; 

        
        maxPendingPayouts = maxPendingPayouts.sub(playerTempReward[myid]);         

        
        playerTempBetValue[myid] = playerBetValue[myid];
        
        playerBetValue[myid] = 0; 

        
        totalBets += 1;

        
        totalWeiWagered += playerTempBetValue[myid];    

        




        if (playerDieResult[myid] == 0 || bytes(result).length == 0 || bytes(proof).length == 0 || oraclize_randomDS_proofVerify__returnCode(myid, result, proof) != 0) {
            emit LogResult(playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], 0, playerTempBetValue[myid], 3, proof);            

            




            if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
                emit LogResult(playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], 0, playerTempBetValue[myid], 4, proof);              
                
                playerPendingWithdrawals[playerTempAddress[myid]] = playerPendingWithdrawals[playerTempAddress[myid]].add(playerTempBetValue[myid]);
            }

            return;
        }

        





        if(playerDieResult[myid] < playerNumber[myid]){ 

            
            contractBalance = contractBalance.sub(playerTempReward[myid]); 

            
            totalWeiWon = totalWeiWon.add(playerTempReward[myid]);              

            
            playerTempReward[myid] = playerTempReward[myid].add(playerTempBetValue[myid]); 

            emit LogResult(playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], playerTempBetValue[myid],1, proof);                            

            
            setMaxProfit();
            
            




            if(!playerTempAddress[myid].send(playerTempReward[myid])){
                emit LogResult(playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], playerTempBetValue[myid], 2, proof);                   
                
                playerPendingWithdrawals[playerTempAddress[myid]] = playerPendingWithdrawals[playerTempAddress[myid]].add(playerTempReward[myid]);                               
            }

            return;

        }

        




        if(playerDieResult[myid] >= playerNumber[myid]){

            emit LogResult(playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], 0, playerTempBetValue[myid], 0, proof);                                

            




            contractBalance = contractBalance.add((playerTempBetValue[myid]-1));                                                                         

            
            setMaxProfit(); 

            


            if(!playerTempAddress[myid].send(1)){
                                
               playerPendingWithdrawals[playerTempAddress[myid]] = playerPendingWithdrawals[playerTempAddress[myid]].add(1);                                
            }                                   

            return;

        }

    }
    
    



    function playerWithdrawPendingTransactions() public 
        payoutsAreActive
        returns (bool)
     {
        uint withdrawAmount = playerPendingWithdrawals[msg.sender];
        playerPendingWithdrawals[msg.sender] = 0;
        
        if (msg.sender.call.value(withdrawAmount)()) {
            return true;
        } else {
            
            
            playerPendingWithdrawals[msg.sender] = withdrawAmount;
            return false;
        }
    }

    
    function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
        return playerPendingWithdrawals[addressToCheck];
    }

    



    function setMaxProfit() internal {
        maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
    }      

    


    function ()
        payable public
        onlyTreasury
    {
        
        contractBalance = contractBalance.add(msg.value);        
        
        setMaxProfit();
    } 

    
    function ownerSetCallbackGasPrice(uint newCallbackGasPrice) public 
		onlyOwner
	{
        oraclize_setCustomGasPrice(newCallbackGasPrice);
    }     

    
    function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
		onlyOwner
	{
    	gasForOraclize = newSafeGasToOraclize;
    }

    
    function ownerUpdateContractBalance(uint newContractBalanceInWei) public 
		onlyOwner
    {        
       contractBalance = newContractBalanceInWei;
    }    

    
    function ownerSetHouseEdge(uint newHouseEdge) public 
		onlyOwner
    {
        houseEdge = newHouseEdge;
    }

    
    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
		onlyOwner
    {
        
        require(newMaxProfitAsPercent <= 50000);
        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }

    
    function ownerSetMinBet(uint newMinimumBet) public 
		onlyOwner
    {
        minBet = newMinimumBet;
    }       

    
    function ownerTransferEther(address sendTo, uint amount) public 
		onlyOwner
    {        
        
        contractBalance = contractBalance.sub(amount);		
        
        setMaxProfit();
        if(!sendTo.send(amount)) revert();
        emit LogOwnerTransfer(sendTo, amount); 
    }

    







    function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
		onlyOwner
    {        
        
        maxPendingPayouts = maxPendingPayouts.sub(originalPlayerProfit);
        
        if(!sendTo.send(originalPlayerBetValue)) revert();
        
        emit LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
    }    

    
    function ownerPauseGame(bool newStatus) public 
		onlyOwner
    {
		gamePaused = newStatus;
    }

    
    function ownerPausePayouts(bool newPayoutStatus) public 
		onlyOwner
    {
		payoutsPaused = newPayoutStatus;
    } 

    
    function ownerSetTreasury(address newTreasury) public 
		onlyOwner
	{
        treasury = newTreasury;
    }         

    
    function ownerChangeOwner(address newOwner) public 
		onlyOwner
	{
        require(newOwner != 0);
        owner = newOwner;
    }

    
    function ownerkill() public 
		onlyOwner
	{
		selfdestruct(owner);
	}    


}