





























pragma solidity ^0.4.0;

contract Bandit is usingOraclize, DSSafeAddSub {

	


	function () public payable {}

    using strings for *;
	
	


    modifier gameIsActive {
        if(gamePaused == true) throw;
		_;
    }
	
	


    modifier betIsValid(uint _betSize) {      
		if(_betSize < minBet || _betSize > maxBet) throw;
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
	
	
	


	bool public gamePaused;
	address public owner;
	uint public minBet;
	uint public maxBet;
	uint32 public gasForOraclize;
	int public totalBets = 0;
	uint public totalWeiWagered = 0;
	uint public totalWeiWon = 0;
	uint public randomQueryID;
	
	


    mapping (bytes32 => address) playerAddress;
    mapping (bytes32 => address) playerTempAddress;
    mapping (bytes32 => bytes32) playerBetId;
    mapping (bytes32 => uint) playerBetValue;
    mapping (bytes32 => uint) playerTempBetValue;       
    mapping (bytes32 => string) playerDieResult;
    mapping (address => uint) playerPendingWithdrawals;      
    mapping (bytes32 => uint) playerTempReward;
	
	
	


    
    event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint BetValue);      
    
    
	event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, string DiceResult, uint Value, uint Multiplier, int Status, bytes Proof);   
    
    event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
    
    event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);
	
	
	


    function Bandit() {

        owner = msg.sender;     
        
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        
        ownerSetMinBet(50000000000000000);
		ownerSetMaxBet(1000000000000000000);
                
        gasForOraclize = 250000;
        
        oraclize_setCustomGasPrice(20000000000 wei);		

    }
	
	
	




    function playerPull() public 
        payable
        gameIsActive
        betIsValid(msg.value)
	{       

        



               
		randomQueryID += 1;
        string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BGD/97q1t/T+kvazlXwudelwzebpvcx6bW5LckCuZDcCeJILY20m+eimHn32fvEDE9eF26eiPl5M15FYdY4MPcrqHdrTUOuYGL2KA2MJ++A4XjNfaCCzJGzxd5FpgTTOZ+eX4lL+X1TcQrkd85VmG6oTwZX8/MM=},\"n\":3,\"min\":1,\"max\":20,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":";
        string memory queryString2 = uint2str(randomQueryID);
        string memory queryString3 = "${[identity] \"}\"}']";
		
		string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());

        string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice());

        bytes32 rngId = oraclize_query("nested", queryString1_2_3, gasForOraclize);
		
		
		
        
		playerBetId[rngId] = rngId;
        
        playerBetValue[rngId] = msg.value;
        
        playerAddress[rngId] = msg.sender;
		
		
        
        LogBet(playerBetId[rngId], playerAddress[rngId], playerBetValue[rngId]);          

    }
	
	
	


    
	function __callback(bytes32 myid, string result, bytes proof) public   
		onlyOraclize
	{  

        
        if (playerAddress[myid]==0x0) throw;	
		
        
        
        var sl_result = result.toSlice();
        sl_result.beyond("[".toSlice()).until("]".toSlice());
        uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());      
		
		

	    
        playerDieResult[myid] = sl_result.beyond("[".toSlice()).until("]".toSlice()).toString();
		
		
		var first_barrel = parseInt(sl_result.split(', '.toSlice()).toString());
		var second_barrel = parseInt(sl_result.split(', '.toSlice()).toString());
		var third_barrel = parseInt(sl_result.split(', '.toSlice()).toString());
        
        
        playerTempAddress[myid] = playerAddress[myid];
        
        delete playerAddress[myid];         

        
        playerTempBetValue[myid] = playerBetValue[myid];
        
        playerBetValue[myid] = 0;
		
		var miltiplier = 0;		

        
        totalBets += 1;

        
        totalWeiWagered += playerTempBetValue[myid];                                                           

        




        if(parseInt(playerDieResult[myid])==0 || bytes(result).length == 0 || bytes(proof).length == 0){                                                     

             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerDieResult[myid], playerTempBetValue[myid], miltiplier, 3, proof);            

            




            if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
                LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerDieResult[myid], playerTempBetValue[myid], miltiplier, 4, proof);              
                
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
            }

            return;
        }

		
		
		


		
		


		if(first_barrel == 7 && second_barrel == 7 && third_barrel == 7)
		{
			miltiplier = 20;
		}
		
		


		if(first_barrel == 4 || first_barrel == 11 || first_barrel == 18 || second_barrel == 13 || second_barrel == 19 || third_barrel == 5 || third_barrel == 11 || third_barrel == 18)
		{
			miltiplier = 2;
		}
		
		


		if((first_barrel == 4 || first_barrel == 11 || first_barrel == 18) && (second_barrel == 13 || second_barrel == 19) && (third_barrel == 5 || third_barrel == 11 || third_barrel == 18))
		{
			miltiplier = 7;
		}
		
		


		if((first_barrel == 1 || first_barrel == 5 || first_barrel == 12 || first_barrel == 14 || first_barrel == 16 || first_barrel == 20) && (second_barrel == 2 || second_barrel == 5|| second_barrel == 8|| second_barrel == 10 || second_barrel == 16 || second_barrel == 20) && (third_barrel == 2 || third_barrel == 4 || third_barrel == 8 || third_barrel == 13 || third_barrel == 15))
		{
			miltiplier = 3;
		}
		
		


		if((first_barrel == 2 || first_barrel == 6 || first_barrel == 9 || first_barrel == 13) && (second_barrel == 1 || second_barrel == 3 || second_barrel == 9 || second_barrel == 11 || second_barrel == 17) && (third_barrel == 1 || third_barrel == 3 || third_barrel == 6 || third_barrel == 9 || third_barrel == 12 || third_barrel == 14 || third_barrel == 20))
		{
			miltiplier = 5;
		}
		
		


		if((first_barrel == 2 || first_barrel == 9) && (second_barrel == 3 || second_barrel == 17) && (third_barrel == 3 || third_barrel == 12 || third_barrel == 14))
		{
			miltiplier = 10;
		}
		
		


		if((first_barrel == 6) && (second_barrel == 1 || second_barrel == 11) && (third_barrel == 6 || third_barrel == 9))
		{
			miltiplier = 12;
		}
		
		


		if((first_barrel == 13) && (second_barrel == 9) && (third_barrel == 1 || third_barrel == 20))
		{
			miltiplier = 15;
		}
		
		
        





        if(miltiplier > 0){ 

			playerTempReward[myid] = playerTempBetValue[myid] * miltiplier;

            
            totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);              

            LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerDieResult[myid], playerTempReward[myid], miltiplier, 1, proof);                            

            
            




            if(!playerTempAddress[myid].send(playerTempReward[myid])){
                LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerDieResult[myid], playerTempReward[myid], miltiplier, 2, proof);                   
                
                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
            }

            return;

        }

        




        if(miltiplier == 0){

            LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerDieResult[myid], playerTempBetValue[myid], miltiplier, 0, proof);                                                                                                      

            


            if(!playerTempAddress[myid].send(1)){
                                
               playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
            }                                   

            return;

        }

    }


	
	
	



    function playerWithdrawPendingTransactions() public 
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
	
	
	


	
	
    







    function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
		onlyOwner
    {
        
        if(!sendTo.send(originalPlayerBetValue)) throw;
        
        LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
    }  	
	
	
    function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
		onlyOwner
	{
    	gasForOraclize = newSafeGasToOraclize;
    }
	
	
    function ownerSetMinBet(uint newMinimumBet) public 
		onlyOwner
    {
        minBet = newMinimumBet;
    }
	
	
    function ownerSetMaxBet(uint newMaxBet) public 
		onlyOwner
    {
        maxBet = newMaxBet;
    } 
	
	
	
    function ownerPauseGame(bool newStatus) public 
		onlyOwner
    {
		gamePaused = newStatus;
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
	
	
    function withdrawBalance(uint256 cash) public 
		onlyOwner
	{
		uint256 balance = this.balance;
        if (balance > cash) {
            owner.send(cash);
        }
	} 
	
}