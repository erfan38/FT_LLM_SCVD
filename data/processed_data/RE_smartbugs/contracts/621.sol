pragma solidity ^0.4.18;































contract Etherwow is usingOraclize, SafeMath {
    
     using strings for *;

    


    modifier betIsValid(uint _betSize, uint _userNumber) {
        require(((((_betSize * (100-(safeSub(_userNumber,1)))) / (safeSub(_userNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize <= maxProfit && _betSize >= minBet && _userNumber >= minNumber && _userNumber <= maxNumber); 
        _;
    }

    


    modifier gameIsActive {
        require(gamePaused == false);
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

    


    modifier onlyOwnerOrOperator {
         require((msg.sender == owner || msg.sender == operator.addr) && msg.sender != 0x0);
         _;
    }

    

 
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;    
    uint constant public maxNumber = 99; 
    uint constant public minNumber = 2;
    
    bool public gamePaused;
    uint32 public gasForOraclize;
    address public owner;
    uint public contractBalance;
    uint public houseEdge;     
    uint public maxProfit;   
    uint public maxProfitAsPercentOfHouse;                    
    uint public minBet; 
    uint public maxPendingPayouts;
    uint public randomQueryID;
    uint public randomGenerateMethod;
    string private randomApiKey;
    
         
    uint public totalBets = 0;
    uint public totalWeiWon = 0;
    uint public totalWeiWagered = 0; 

    
    Operator public operator;

    struct Operator{
        address addr;
        bool refundPermission;  
        uint refundAmtApprove;  
    }

 

    


    mapping (bytes32 => address) public userAddress;
    mapping (bytes32 => address) public userTempAddress;
    mapping (bytes32 => bytes32) public userBetId;
    mapping (bytes32 => uint) public  userBetValue;
    mapping (bytes32 => uint) public  userTempBetValue;               
    mapping (bytes32 => uint) public  userDieResult;
    mapping (bytes32 => uint) public  userNumber;
    mapping (address => uint) public  userPendingWithdrawals;      
    mapping (bytes32 => uint) public  userProfit;
    mapping (bytes32 => uint) public  userTempReward;           
    
    mapping (bytes32 => uint8) public  betStatus;           

    


    
    event LogBet(bytes32 indexed BetID, address indexed UserAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint UserNumber, uint RandomQueryID);      
    
    event LogResult(bytes32 indexed BetID, address indexed UserAddress, uint UserNumber, uint DiceResult, uint Value, uint8 Status, uint RandomGenerateMethod, bytes Proof, uint indexed SerialNumberOfResult);   
    
    event LogRefund(bytes32 indexed BetID, address indexed UserAddress, uint indexed RefundValue);
    
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);


    


    function Etherwow() {

        owner = msg.sender;
        oraclize_setNetwork(networkID_auto);        
        
        ownerSetHouseEdge(990);
        
        ownerSetMaxProfitAsPercentOfHouse(10000);
        
        ownerSetMinBet(100000000000000000);        
                
        gasForOraclize = 250000;  
        
        oraclize_setCustomGasPrice(20000000000 wei);
        
        randomGenerateMethod = 0; 

    }

    





    function generateRandomNum() internal returns(bytes32){
        
        if (randomGenerateMethod == 0){
                randomQueryID += 1;
                string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":";
                string memory queryString1_1 = ",\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":";
                queryString1 = queryString1.toSlice().concat(randomApiKey.toSlice());
                queryString1 = queryString1.toSlice().concat(queryString1_1.toSlice());

                string memory queryString2 = uint2str(randomQueryID);
                string memory queryString3 = "${[identity] \"}\"}']";

                string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());

                string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice()); 

                oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
                return oraclize_query("nested", queryString1_2_3, gasForOraclize);               
        }

        
        if (randomGenerateMethod == 1){
                randomQueryID += 1;
                uint N = 8; 
                uint delay = 0; 
                oraclize_setProof(proofType_Ledger);
                return oraclize_newRandomDSQuery(delay, N, gasForOraclize); 
                
        }
        

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
        
        betStatus[rngId] = 5;
        
        emit LogBet(userBetId[rngId], userAddress[rngId], safeAdd(userBetValue[rngId], userProfit[rngId]), userProfit[rngId], userBetValue[rngId], userNumber[rngId], randomQueryID);          

    }   
             

    





    function __callback(bytes32 myid, string result, bytes proof) public   
        onlyOraclize
    {  
        
        require(userAddress[myid]!=0x0);

        
        if (randomGenerateMethod == 0){
                
                var sl_result = result.toSlice();
                sl_result.beyond("[".toSlice()).until("]".toSlice());
                uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          

                
                userDieResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());                 
        } 

                
        if (randomGenerateMethod == 1){
                uint maxRange = 100; 
                userDieResult[myid] = uint(sha3(result)) % maxRange + 1; 
        }
      
        
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
              
             
             betStatus[myid] = 3;
            




            if(!userTempAddress[myid].send(userTempBetValue[myid])){
                
                betStatus[myid] = 4;              
                
                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempBetValue[myid]);                        
            }
            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);
            return;
        }

        





        if(userDieResult[myid] < userNumber[myid]){ 

            
            contractBalance = safeSub(contractBalance, userTempReward[myid]); 

            
            totalWeiWon = safeAdd(totalWeiWon, userTempReward[myid]);              

            
            userTempReward[myid] = safeAdd(userTempReward[myid], userTempBetValue[myid]); 

            
            betStatus[myid] = 1;                           

            
            setMaxProfit();
            
            




            if(!userTempAddress[myid].send(userTempReward[myid])){
                
                betStatus[myid] = 2;                   
                
                userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], userTempReward[myid]);                               
            }
            
            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);
            return;

        }

        




        if(userDieResult[myid] >= userNumber[myid]){

            
            betStatus[myid] = 0;
            emit LogResult(userBetId[myid], userTempAddress[myid], userNumber[myid], userDieResult[myid], userTempBetValue[myid], betStatus[myid], randomGenerateMethod, proof, serialNumberOfResult);                                

            




            contractBalance = safeAdd(contractBalance, (userTempBetValue[myid]-1));                                                                         

            
            setMaxProfit(); 

            


            if(!userTempAddress[myid].send(1)){
                                
               userPendingWithdrawals[userTempAddress[myid]] = safeAdd(userPendingWithdrawals[userTempAddress[myid]], 1);                                
            }                                   

            return;

        }

    }
    
    



    function userWithdrawPendingTransactions() public 
        gameIsActive
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
        onlyOwnerOrOperator
    {
        
        contractBalance = safeAdd(contractBalance, msg.value);        
        
        setMaxProfit();
    } 
     
     







  
    function ownerModOperator(address newAddress, bool newRefundPermission, uint newRefundAmtApprove) public 
        onlyOwner
    {
        operator.addr = newAddress;
        operator.refundPermission = newRefundPermission;
        operator.refundAmtApprove = newRefundAmtApprove;            
    }

    


    function ownerSetCallbackGasPrice(uint newCallbackGasPrice) public 
        onlyOwnerOrOperator
    {
        oraclize_setCustomGasPrice(newCallbackGasPrice);
    }     

    


    function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
        onlyOwnerOrOperator
    {
        gasForOraclize = newSafeGasToOraclize;
    }

    


    function ownerUpdateContractBalance(uint newContractBalanceInWei) public 
        onlyOwnerOrOperator
    {        
       contractBalance = newContractBalanceInWei;
    }    

    

    
    function ownerSetHouseEdge(uint newHouseEdge) public 
        onlyOwnerOrOperator
    {
        if(msg.sender == operator.addr && newHouseEdge > 990) throw;
        houseEdge = newHouseEdge;
    }

    

    
    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
        onlyOwnerOrOperator
    {
        
        require(newMaxProfitAsPercent <= 50000);

        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }

    

        
    function ownerSetMinBet(uint newMinimumBet) public 
        onlyOwnerOrOperator
    {
        minBet = newMinimumBet;
    }       

    

  
    function ownerTransferEther(address sendTo, uint amount) public 
        onlyOwner
    {        
        
        contractBalance = safeSub(contractBalance, amount);     
        
        setMaxProfit();
        sendTo.transfer(amount);
        emit LogOwnerTransfer(sendTo, amount); 
    }

    














    function ownerRefundUser(bytes32 originalUserBetId, address sendTo, uint originalUserProfit, uint originalUserBetValue) public 
        onlyOwnerOrOperator
    {        
        require(msg.sender == owner || (msg.sender == operator.addr && operator.refundPermission == true && safeToSubtract(operator.refundAmtApprove, originalUserBetValue)));
        
        maxPendingPayouts = safeSub(maxPendingPayouts, originalUserProfit);
        
        sendTo.transfer(originalUserBetValue);
        
        if(msg.sender == operator.addr){
            operator.refundAmtApprove = operator.refundAmtApprove -  originalUserBetValue;
        }
        
        betStatus[originalUserBetId] = 6;
        
        emit LogRefund(originalUserBetId, sendTo, originalUserBetValue);        
    }    

    


 
    function ownerPauseGame(bool newStatus) public 
        onlyOwnerOrOperator
    {
        gamePaused = newStatus;
    }


    


 
    function ownerChangeOwner(address newOwner) public 
        onlyOwner
    {
        owner = newOwner;
    }

    


 
    function ownerSetRandomApiKey(string newApiKey) public 
        onlyOwnerOrOperator
    {
        randomApiKey = newApiKey;
    } 

    


  
    function ownerSetRandomGenerateMethod(uint newRandomGenerateMethod) public 
        onlyOwnerOrOperator
    {
        randomGenerateMethod = newRandomGenerateMethod;
    } 
    
    

 
    function ownerkill() public 
        onlyOwner
    {
        selfdestruct(owner);
    }    


}