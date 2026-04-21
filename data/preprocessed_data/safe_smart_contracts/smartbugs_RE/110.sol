pragma solidity ^0.4.13;

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicCrowdsale is ICrowdsaleProcessor {
  event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);

  
  address public fundingAddress;

  
  function BasicCrowdsale(
    address _owner,
    address _manager
  )
    public
  {
    owner = _owner;
    manager = _manager;
  }

  
  
  
  
  function mintETHRewards(
    address _contract,  
    uint256 _amount     
  )
    public
    onlyManager() 
  {
    require(_contract.call.value(_amount)());
  }

  
  function stop() public onlyManager() hasntStopped()  {
    
    if (started) {
      require(!isFailed());
      require(!isSuccessful());
    }
    stopped = true;
  }

  
  
  function start(
    uint256 _startTimestamp,
    uint256 _endTimestamp,
    address _fundingAddress
  )
    public
    onlyManager()   
    hasntStarted()  
    hasntStopped()  
  {
    require(_fundingAddress != address(0));

    
    require(_startTimestamp >= block.timestamp);

    
    require(_endTimestamp > _startTimestamp);
    duration = _endTimestamp - _startTimestamp;

    
    require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);

    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
    fundingAddress = _fundingAddress;

    
    started = true;

    emit CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
  }

  
  function isFailed()
    public
    constant
    returns(bool)
  {
    return (
      
      started &&

      
      block.timestamp >= endTimestamp &&

      
      totalCollected < minimalGoal
    );
  }

  
  function isActive()
    public
    constant
    returns(bool)
  {
    return (
      
      started &&

      
      totalCollected < hardCap &&

      
      block.timestamp >= startTimestamp &&
      block.timestamp < endTimestamp
    );
  }

  
  function isSuccessful()
    public
    constant
    returns(bool)
  {
    return (
      
      totalCollected >= hardCap ||

      
      (block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
    );
  }
}
