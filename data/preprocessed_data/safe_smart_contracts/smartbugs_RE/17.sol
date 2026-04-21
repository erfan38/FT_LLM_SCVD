pragma solidity ^0.4.19;













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








contract TokensGate is MintableToken {
  event Burn(address indexed burner, uint256 value);

  string public constant name = "TokensGate";
  string public constant symbol = "TGC";
  uint8 public constant decimals = 18;
  
  bool public AllowTransferGlobal = false;
  bool public AllowTransferLocal = false;
  bool public AllowTransferExternal = false;
  bool public AllowBurnByCreator = true;
  bool public AllowBurn = true;
  
  mapping(address => uint256) public Whitelist;
  mapping(address => uint256) public LockupList;
  mapping(address => bool) public WildcardList;
  mapping(address => bool) public Managers;
    
  function allowTransfer(address _from, address _to) public view returns (bool) {
    if (WildcardList[_from])
      return true;
      
    if (LockupList[_from] > now)
      return false;
    
    if (!AllowTransferGlobal) {
      if (AllowTransferLocal && Whitelist[_from] != 0 && Whitelist[_to] != 0 && Whitelist[_from] < now && Whitelist[_to] < now)
        return true;
            
      if (AllowTransferExternal && Whitelist[_from] != 0 && Whitelist[_from] < now)
        return true;
        
      return false;
    }
      
    return true;
  }
    
  function allowManager() public view returns (bool) {
    if (msg.sender == owner)
      return true;
    
    if (Managers[msg.sender])
      return true;
      
    return false;
  }
    
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(allowTransfer(msg.sender, _to));
      
    return super.transfer(_to, _value);
  }
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(allowTransfer(_from, _to));
      
    return super.transferFrom(_from, _to, _value);
  }
    
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply.add(_amount) <= 1000000000000000000000000000);

    return super.mint(_to, _amount);
  }
    
  function burn(uint256 _value) public {
    require(AllowBurn);
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(msg.sender, _value);
    Transfer(msg.sender, address(0), _value);
  }
  
  function burnByCreator(address _burner, uint256 _value) onlyOwner public {
    require(AllowBurnByCreator);
    require(_value <= balances[_burner]);
    
    balances[_burner] = balances[_burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_burner, _value);
    Transfer(_burner, address(0), _value);
  }
  
  function finishBurning() onlyOwner public returns (bool) {
    AllowBurn = false;
    return true;
  }
  
  function finishBurningByCreator() onlyOwner public returns (bool) {
    AllowBurnByCreator = false;
    return true;
  }
  
  function setManager(address _manager, bool _status) onlyOwner public {
    Managers[_manager] = _status;
  }
  
  function setAllowTransferGlobal(bool _status) onlyOwner public {
    AllowTransferGlobal = _status;
  }
  
  function setAllowTransferLocal(bool _status) onlyOwner public {
    AllowTransferLocal = _status;
  }
  
  function setAllowTransferExternal(bool _status) onlyOwner public {
    AllowTransferExternal = _status;
  }
    
  function setWhitelist(address _address, uint256 _date) public {
    require(allowManager());
    
    Whitelist[_address] = _date;
  }
  
  function setLockupList(address _address, uint256 _date) onlyOwner public {
    LockupList[_address] = _date;
  }
  
  function setWildcardList(address _address, bool _status) onlyOwner public {
    WildcardList[_address] = _status;
  }
  
  function transferTokens(address walletToTransfer, address tokenAddress, uint256 tokenAmount) onlyOwner payable public {
    ERC20 erc20 = ERC20(tokenAddress);
    erc20.transfer(walletToTransfer, tokenAmount);
  }
  
  function transferEth(address walletToTransfer, uint256 weiAmount) onlyOwner payable public {
    require(walletToTransfer != address(0));
    require(address(this).balance >= weiAmount);
    require(address(this) != walletToTransfer);

    require(walletToTransfer.call.value(weiAmount)());
  }
}