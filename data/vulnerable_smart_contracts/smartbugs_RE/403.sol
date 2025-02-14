pragma solidity ^0.4.18;































pragma solidity >= 0.4.1 < 0.5;

contract Etheroll is usingOraclize, DSSafeAddSub {
    
     using strings for *;

    


    modifier betIsValid(uint _betSize, uint _playerSize) {      
        if(((((_betSize * (10-_playerSize)) / _playerSize+_betSize))*houseEdge/houseEdgeDivisor)-_betSize > maxProfit || _betSize < minBet || _playerSize < minNumber || _playerSize > maxNumber) throw;        
        _;
    }

    


    modifier gameIsActive {
        if(gamePaused == true) throw;
        _;
    }    

    


    modifier payoutsAreActive {
        if(payoutsPaused == true) throw;
        _;
    }    

    


    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }

    


    modifier onlyOwner {
         if (msg.sender != owner) throw;
         _;
    }

    


    modifier onlyTreasury {
         if (msg.sender != treasury) throw;
         _;
    }    

    

 
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;    
    uint constant public maxNumber = 9; 
    uint constant public minNumber = 1;
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
    uint public maxPendingPayouts;
    
    uint public totalWeiWon = 0;
    
    uint public totalWeiWagered = 0; 
    uint public randomQueryID;
    string public fullurl;
    string public lastresult;

    


    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => address) playerTempAddress;
    mapping (bytes32 => bytes32) playerBetId;
    mapping (bytes32 => uint) playerBetValue;
    mapping (bytes32 => uint) playerTempBetValue;               
    mapping (bytes32 => uint) playerDieResult;
    
    mapping (bytes32 => uint[]) playerNumbers;
    mapping (address => uint) playerPendingWithdrawals;      
    mapping (bytes32 => uint) playerProfit;
    mapping (bytes32 => uint) playerTempReward;           

    


    
    event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint[] PlayerNumbers, uint RandomQueryID);      
    
    
    event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint[] PlayerNumbers, uint DiceResult, uint Value, int Status, bytes Proof);   
    
    event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
    
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               


    


    function Etheroll() {

        owner = msg.sender;
        treasury = msg.sender;
        oraclize_setNetwork(networkID_auto);        
        
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        
        ownerSetHouseEdge(990);
        
        ownerSetMaxProfitAsPercentOfHouse(100000);
        
        ownerSetMinBet(200000000000000000);        
                
        gasForOraclize = 305000;  
        
        oraclize_setCustomGasPrice(15000000000 wei);              

    }

    




    function playerRollDice(uint [] rollUnders) public 
        payable
        gameIsActive
        betIsValid(msg.value, rollUnders.length)
    {       

        



       
        randomQueryID += 1;
        
        string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\", \"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\"";
        
        string memory queryString2 = uint2str(randomQueryID);
        
        string memory queryString3 = "\",\"params\":{\"n\":\"1\",\"min\":1,\"max\":10,\"replacement\":true,\"base\":10,\"apiKey\":${[decrypt] BBMNZebnAxMKyKaAHrEDQOwQxVfwJAl2gHbuoaUCoR2G5GP5XY3miS3zd60ZaHos6zkdnyS1nt/+VTOf+eSC6mbvQjbclxDZOJCVJE6E65eJoLXmyTcN4S9I8JCUa/VLTncrKnoy+7B036FHKBylAnkz1/y04kIa2w==}}']";
     
        string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());

        string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice());
        
        fullurl = queryString1_2_3;
        bytes32 rngId = oraclize_query("nested", queryString1_2_3, gasForOraclize);  
        
        playerBetId[rngId] = rngId;
        
        playerNumbers[rngId] = rollUnders;
        
        playerBetValue[rngId] = msg.value;
        
        playerAddress[rngId] = msg.sender;
                             
        playerProfit[rngId] = ((((msg.value * (10-rollUnders.length)) / rollUnders.length+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
        
        maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
        
        if(maxPendingPayouts >= contractBalance) throw;
        
        LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumbers[rngId], randomQueryID);          

    }   

    


    
    function __callback(bytes32 myid, string result, bytes proof) public   
        onlyOraclize
        payoutsAreActive
    {  

        lastresult = result;
        
        if (playerAddress[myid]==0x0) throw;
        
        
        var sl_result = result.toSlice();
        sl_result.beyond("[".toSlice()).until("]".toSlice());
        uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          

        playerDieResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());        
        
        playerTempAddress[myid] = playerAddress[myid];
        
        delete playerAddress[myid];

        
        playerTempReward[myid] = playerProfit[myid];
        
        playerProfit[myid] = 0; 

        
        maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);         

        
        playerTempBetValue[myid] = playerBetValue[myid];
        
        playerBetValue[myid] = 0; 

        
        totalBets += 1;

        
        totalWeiWagered += playerTempBetValue[myid];                                                           

        




        if(playerDieResult[myid] == 0 || bytes(result).length == 0)
        
        {                                                     

             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumbers[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof);            

            




            if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
                LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumbers[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof);              
                
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
            }

            return;
        }

        





        bool hitted=false;
        for(uint8 i=0;i<playerNumbers[myid].length;i++)
        {
            if(playerNumbers[myid][i] == playerDieResult[myid])
            {
                hitted=true;
                break;
            }
        }
        
        if(hitted)
        { 

            
            contractBalance = safeSub(contractBalance, playerTempReward[myid]); 

            
            totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);              

            
            playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]); 

            LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumbers[myid], playerDieResult[myid], playerTempReward[myid], 1, proof);                            

            
            setMaxProfit();
            
            




            if(!playerTempAddress[myid].send(playerTempReward[myid])){
                LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumbers[myid], playerDieResult[myid], playerTempReward[myid], 2, proof);                   
                
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
            }

            return;

        }

        




        
        else{

            LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumbers[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof);                                

            




            contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid]-1));                                                                         

            
            setMaxProfit(); 

            


            if(!playerTempAddress[myid].send(1)){
                                
               playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
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
        payable
        onlyTreasury
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
        
        if(newMaxProfitAsPercent > 900000) throw;
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
        if(!sendTo.send(amount)) throw;
        LogOwnerTransfer(sendTo, amount); 
    }
    
    
    function ownerTransferAllEther() public 
        onlyOwner
    {        
        
        contractBalance = 0;
        
        setMaxProfit();
        if(!owner.send(this.balance)) revert();
        LogOwnerTransfer(owner, this.balance); 
    }

    







    function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
        onlyOwner
    {        
        
        maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
        
        if(!sendTo.send(originalPlayerBetValue)) throw;
        
        LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
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
        owner = newOwner;
    }

    
    function ownerkill() public 
        onlyOwner
    {
        suicide(owner);
    }    


}