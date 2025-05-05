


contract PreICOProxyBuyer is Ownable, Haltable, SafeMath {

  
  uint public investorCount;

  
  uint public weiRaisedTotal;

  
  address[] public investors;

  
  mapping(address => uint) public balances;

  
  mapping(address => uint) public claimed;

  
  uint public freezeEndsAt;

  
  uint public weiMinimumLimit;

  
  uint public weiMaximumLimit;

  
  uint public weiCap;

  
  uint public tokensBought;

   
  uint public claimCount;

  uint public totalClaimed;

  
  Crowdsale public crowdsale;

  
  enum State{Unknown, Funding, Distributing, Refunding}

  
  event Invested(address investor, uint value, uint128 customerId);

  
  event Refunded(address investor, uint value);

  
  event TokensBoughts(uint count);

  
  event Distributed(address investors, uint count);

  


  function PreICOProxyBuyer(address _owner, uint _freezeEndsAt, uint _weiMinimumLimit, uint _weiMaximumLimit, uint _weiCap) {

    owner = _owner;

    
    if(_freezeEndsAt == 0) {
      throw;
    }

    
    if(_weiMinimumLimit == 0) {
      throw;
    }

    if(_weiMaximumLimit == 0) {
      throw;
    }

    weiMinimumLimit = _weiMinimumLimit;
    weiMaximumLimit = _weiMaximumLimit;
    weiCap = _weiCap;
    freezeEndsAt = _freezeEndsAt;
  }

  


  function getToken() public constant returns(FractionalERC20) {
    if(address(crowdsale) == 0)  {
      throw;
    }

    return crowdsale.token();
  }

  


  function invest(uint128 customerId) private {

    
    if(getState() != State.Funding) throw;

    if(msg.value == 0) throw; 

    address investor = msg.sender;

    bool existing = balances[investor] > 0;

    balances[investor] = safeAdd(balances[investor], msg.value);

    
    if(balances[investor] < weiMinimumLimit || balances[investor] > weiMaximumLimit) {
      throw;
    }

    
    if(!existing) {
      investors.push(investor);
      investorCount++;
    }

    weiRaisedTotal = safeAdd(weiRaisedTotal, msg.value);
    if(weiRaisedTotal > weiCap) {
      throw;
    }

    Invested(investor, msg.value, customerId);
  }

  function investWithId(uint128 customerId) public stopInEmergency payable {
    invest(customerId);
  }

  function investWithoutId() public stopInEmergency payable {
    invest(0x0);
  }


  




  function buyForEverybody() stopInEmergency public {

    if(getState() != State.Funding) {
      
      throw;
    }

    
    if(address(crowdsale) == 0) throw;

    
    crowdsale.invest.value(weiRaisedTotal)(address(this));

    
    tokensBought = getToken().balanceOf(address(this));

    if(tokensBought == 0) {
      
      throw;
    }

    TokensBoughts(tokensBought);
  }

  


  function getClaimAmount(address investor) public constant returns (uint) {

    
    if(getState() != State.Distributing) {
      throw;
    }
    return safeMul(balances[investor], tokensBought) / weiRaisedTotal;
  }

  


  function getClaimLeft(address investor) public constant returns (uint) {
    return safeSub(getClaimAmount(investor), claimed[investor]);
  }

  


  function claimAll() {
    claim(getClaimLeft(msg.sender));
  }

  



  function claim(uint amount) stopInEmergency {
    address investor = msg.sender;

    if(amount == 0) {
      throw;
    }

    if(getClaimLeft(investor) < amount) {
      
      throw;
    }

    
    if(claimed[investor] == 0) {
      claimCount++;
    }

    claimed[investor] = safeAdd(claimed[investor], amount);
    totalClaimed = safeAdd(totalClaimed, amount);
    getToken().transfer(investor, amount);

    Distributed(investor, amount);
  }

  


  function refund() stopInEmergency {

    
    if(getState() != State.Refunding) throw;

    address investor = msg.sender;
    if(balances[investor] == 0) throw;
    uint amount = balances[investor];
    delete balances[investor];
    
    
    
    if(!(investor.call.value(amount)())) throw;
    Refunded(investor, amount);
  }

  


  function setCrowdsale(Crowdsale _crowdsale) public onlyOwner {
    crowdsale = _crowdsale;

    
    if(!crowdsale.isCrowdsale()) true;
  }

  


  function getState() public returns(State) {
    if(tokensBought == 0) {
      if(now >= freezeEndsAt) {
         return State.Refunding;
      } else {
        return State.Funding;
      }
    } else {
      return State.Distributing;
    }
  }

  
  function() payable {
    throw;
  }
}