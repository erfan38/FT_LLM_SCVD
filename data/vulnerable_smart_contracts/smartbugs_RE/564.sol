pragma solidity ^0.4.18;































contract Etheroll is usingOraclize, SafeMath {
    
     using strings for *;

    


    modifier betIsValid(uint _betSize, uint _userNumber) {
        require(((((_betSize * (100-(safeSub(_userNumber,1)))) / (safeSub(_userNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize <= maxProfit && _betSize >= minBet && _userNumber >= minNumber && _userNumber <= maxNumber); 
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
    uint public maxPendingPayouts;
    uint public randomQueryID;
    
         
    uint public totalBets = 0;
    uint public totalWeiWon = 0;
    uint public totalWeiWagered = 0; 

    

    


    mapping (bytes32 => address) userAddress;
    mapping (bytes32 => address) userTempAddress;
    mapping (bytes32 => bytes32) userBetId;
    mapping (bytes32 => uint) userBetValue;
    mapping (bytes32 => uint) userTempBetValue;               
    mapping (bytes32 => uint) userDieResult;
    mapping (bytes32 => uint) userNumber;
    mapping (address => uint) userPendingWithdrawals;      
    mapping (bytes32 => uint) userProfit;
    mapping (bytes32 => uint) userTempReward;           

    


    
    event LogBet(bytes32 indexed BetID, address indexed UserAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint UserNumber, uint RandomQueryID);      
    
    
    event LogResult(bytes32 indexed BetID, address indexed UserAddress, uint UserNumber, uint DiceResult, uint Value, int Status, bytes Proof);   
    
    event LogRefund(bytes32 indexed BetID, address indexed UserAddress, uint indexed RefundValue);
    
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);

    
    event logString(string stringtolog);
    event logUint8(uint8 _uint8);


    


    function Etheroll() {

        owner = msg.sender;
        treasury = msg.sender;
        oraclize_setNetwork(networkID_auto);        
        
        oraclize_setProof(proofType_Ledger);
        
        ownerSetHouseEdge(990);
        
        
        
        ownerSetMaxProfitAsPercentOfHouse(1000000);
        
        ownerSetMinBet(100000000000000000);        
                
        gasForOraclize = 250000;  
        
        oraclize_setCustomGasPrice(20000000000 wei); 

    }
    



    function generateRandomNum() internal returns(bytes32){
        
        randomQueryID += 1;        
        uint numberOfBytes = 2;
        uint delay = 0;
        return oraclize_newRandomDSQuery(delay, numberOfBytes, gasForOraclize); 
    }

    




    function userRollDice(uint rollUnder) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollUnder)
    {       

        bytes32 rngId = generateRandomNum(); 
       
        
        userBetId[rngId] = rngId;
        
        userNumber[rngId] = rollUnder;
        
        userBetValue[rngId] = msg.value;
        
        userAddress[rngId] = msg.sender;
                             
        userProfit[rngId] = ((((msg.value * (100-(safeSub(rollUnder,1)))) / (safeSub(rollUnder,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
        
        maxPendingPayouts = safeAdd(maxPendingPayouts, userProfit[rngId]);
        
        require(maxPendingPayouts < contractBalance);
        
        LogBet(userBetId[rngId], userAddress[rngId], safeAdd(userBetValue[rngId], userProfit[rngId]), userProfit[rngId], userBetValue[rngId], userNumber[rngId], randomQueryID);          

    }   
             

    


    
    function __callback(bytes32 myid, string result, bytes proof) public   
        onlyOraclize
        payoutsAreActive
    {  

        
        require(userAddress[myid]!= 0x0);

        
        require(oraclize_randomDS_proofVerify__returnCode(myid, result, proof) == 0); 
               
        uint maxRange = 100; 
        
		
        userDieResult[myid] = uint(sha3(result)) % maxRange + 1; 
      
        
        userTempAddress[myid] = userAddress[myid];
        
        delete userAddress[myid];

        
        userTempReward[myid] = userProfit[myid];
        
        userProfit[myid] = 0; 

        
        maxPendingPayouts = safeSub(maxPendingPayouts, userTempReward[myid]);         

        
        userTempBetValue[myid] = userBetValue[myid];
        
        userBetValue[myid] = 0; 

        
        totalBets += 1;

        
        totalWeiWagered += userTempBetValue[myid];                                                           

        




        if(userDieResult[myid] == 0 || bytes(result).length == 0 || bytes(proof).length == 0){                                                     

             LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], 3, proof);            

            




            if(!userTempAddress[myid].send(userTempBetValue[myid])){
                LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], 4, proof);              
                
                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempBetValue[myid]);                        
            }

            return;
        }

        





        if(userDieResult[myid] < userNumber[myid]){ 

            
            contractBalance = safeSub(contractBalance, userTempReward[myid]); 

            
            totalWeiWon = safeAdd(totalWeiWon, userTempReward[myid]);              

            
            userTempReward[myid] = safeAdd(userTempReward[myid], userTempBetValue[myid]); 

            LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempReward[myid], 1, proof);                            

            
            setMaxProfit();
            
            




            if(!userTempAddress[myid].send(userTempReward[myid])){
                LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempReward[myid], 2, proof);                   
                
                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempReward[myid]);                               
            }

            return;

        }

        




        if(userDieResult[myid] >= userNumber[myid]){

            LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], 0, proof);                                

            




            contractBalance = safeAdd(contractBalance, (userTempBetValue[myid]-1));                                                                         

            
            setMaxProfit(); 

            


            if(!userTempAddress[myid].send(1)){
                                
               userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], 1);                                
            }                                   

            return;

        }

    }
    
    



    function userWithdrawPendingTransactions() public 
        payoutsAreActive
        returns (bool)
     {
        uint withdrawAmount = userPendingWithdrawals[msg.sender];
        userPendingWithdrawals[msg.sender] = 0;
        
        if (msg.sender.call.value(withdrawAmount)()) {
            return true;
        } else {
            
            
            userPendingWithdrawals[msg.sender] = withdrawAmount;
            return false;
        }
    }

    
    function userGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
        return userPendingWithdrawals[addressToCheck];
    }

    



    function setMaxProfit() internal {
        maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
    }      

    


    function ()
        payable
        onlyOwner
    {
        
        contractBalance = safeAdd(contractBalance, msg.value);        
        
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
        
        contractBalance = safeSub(contractBalance, amount);     
        
        setMaxProfit();
        sendTo.transfer(amount);
        LogOwnerTransfer(sendTo, amount); 
    }

    







    function ownerRefundUser(bytes32 originalUserBetId, address sendTo, uint originalUserProfit, uint originalUserBetValue) public 
        onlyOwner
    {        
        
        maxPendingPayouts = safeSub(maxPendingPayouts, originalUserProfit);
        
        sendTo.transfer(originalUserBetValue);
        
        LogRefund(originalUserBetId, sendTo, originalUserBetValue);        
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

    
    function ownerChangeOwner(address newOwner) public 
        onlyOwner
    {
        owner = newOwner;
    }
    
    
    function ownerkill() public 
        onlyOwner
    {
        selfdestruct(owner);
    }    


}