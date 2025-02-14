pragma solidity ^0.4.18;



contract IChain is StandardToken {
  string public name = 'I Chain';
  string public symbol = 'ISC';
  uint8 public decimals = 18;
  uint public totalSupply = 1000000000 ether;
  
   address public beneficiary;  
   address public owner; 
   
    uint256 public fundingGoal ;   
	
    uint256 public amountRaised ;   
	
	uint256 public amountRaisedIsc ;  
  
  
  uint256 public price;
  
  uint256 public totalDistributed = 800000000 ether;
  
  uint256 public totalRemaining;

  
  uint256 public tokenReward = totalSupply.sub(totalDistributed);

     bool public fundingGoalReached = false;  
     bool public crowdsaleClosed = false;  
  
    
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amounteth, bool isContribution);
  
  function IChain(address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
		uint _price
         ) public {
		
			beneficiary = ifSuccessfulSendTo;
            fundingGoal = fundingGoalInEthers * 1 ether;       
            price = _price;          
			owner = msg.sender;
			balances[msg.sender] = totalDistributed;
			
  }
 
    modifier canDistr() {
        require(!crowdsaleClosed);
        _;
    }
	  modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
   
	
	
   function () external payable {
		
		require(!crowdsaleClosed);
		require(!fundingGoalReached);
        getTokens();
     }	 
	
	
	
  function finishDistribution() onlyOwner canDistr  public returns (bool) {
		
		
        crowdsaleClosed = true;
		
		uint256 amount = tokenReward.sub(amountRaisedIsc);
		
		balances[beneficiary] = balances[beneficiary].add(amount);	
		
		
		require(msg.sender.call.value(amountRaised)());	
				
        return true;
    }	
 
  function extractTokenEth(uint amount) onlyOwner  public returns (bool) {	 
		require(msg.sender.call.value(amount)());			
        return true;
    }		

	
  function getTokens() payable{
			
		if (amountRaised >= fundingGoal) {
            fundingGoalReached = true;
			return;
        } 			
        address investor = msg.sender; 
		uint amount = msg.value;
        distr(investor,amount);	
    }
	
	 
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
		
		amountRaised += _amount;		
		
		_amount=_amount.mul(price);
	 	
		amountRaisedIsc += _amount;
		
        balances[_to] = balances[_to].add(_amount);		
        FundTransfer(msg.sender,_amount,true);
		  		
        return true;           
		
    }

  
}