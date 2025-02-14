pragma solidity ^0.4.18;












contract EnishiCoin is ERC223, OwnerSigneture
{
  using SafeMath for uint256;

  string public name = "EnishiCoin";
  string public symbol = "XENS";
  uint8 public decimals = 8;
  uint256 dec = 1e8;

  uint256 public initialSupply = 100e8 * dec; 
  uint256 public totalSupply;
  bool public mintingFinished = false;

  address public temporaryAddress = 0x092dEBAEAD027b43301FaFF52360B2B0538b0c98;

  mapping (address => uint) balances;
  mapping(address => mapping (address => uint256)) public allowance;
  mapping (address => bool) public frozenAccount;
  mapping (address => uint256) public unlockUnixTime;

  mapping (address => uint) public temporaryBalances;
  mapping (address => uint256) temporaryLimitUnixTime;

  event FrozenFunds(address indexed target, bool frozen);
  event LockedFunds(address indexed target, uint256 locked);
  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  function EnishiCoin(address[] _owners) OwnerSigneture(_owners) public
  {
    owners = _owners;
    totalSupply = initialSupply;
    for (uint i = 0; i < _owners.length; i++) {
        balances[_owners[i]] = totalSupply.div(_owners.length);
    }
  }

  function name() public view returns (string _name)
  {
    return name;
  }

  function symbol() public view returns (string _symbol)
  {
    return symbol;
  }

  function decimals() public view returns (uint8 _decimals)
  {
    return decimals;
  }

  function totalSupply() public view returns (uint256 _totalSupply)
  {
    return totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint balance)
  {
    return balances[_owner];
  }

  modifier onlyPayloadSize(uint256 _size)
  {
    assert(msg.data.length >= _size + 4);
    _;
  }

  




  function freezeAccounts(address[] _targets, bool _isFrozen) signed public
  {
    require(_targets.length > 0);

    for (uint i = 0; i < _targets.length; i++) {
      require(_targets[i] != 0x0);
      frozenAccount[_targets[i]] = _isFrozen;
      FrozenFunds(_targets[i], _isFrozen);
    }
  }

  




  function lockupAccounts(address[] _targets, uint[] _unixTimes) signed public
  {
    require(true
      && _targets.length > 0
      && _targets.length == _unixTimes.length
    );

    for(uint i = 0; i < _targets.length; i++) {
      require(unlockUnixTime[_targets[i]] < _unixTimes[i]);
      unlockUnixTime[_targets[i]] = _unixTimes[i];
      LockedFunds(_targets[i], _unixTimes[i]);
    }
  }

  


  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success)
  {
    require(true
      && _value > 0
      && frozenAccount[msg.sender] == false
      && frozenAccount[_to] == false
      && now > unlockUnixTime[msg.sender]
      && now > unlockUnixTime[_to]
    );

    if (isContract(_to)) {
      if (balanceOf(msg.sender) < _value) {
        revert();
      }
      balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
      balances[_to] = SafeMath.add(balanceOf(_to), _value);
      assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
      Transfer(msg.sender, _to, _value, _data);
      Transfer(msg.sender, _to, _value);
      return true;
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  


  function transfer(address _to, uint _value, bytes _data) public returns (bool success)
  {
    require(true
      && _value > 0
      && frozenAccount[msg.sender] == false
      && frozenAccount[_to] == false
      && now > unlockUnixTime[msg.sender]
      && now > unlockUnixTime[_to]
    );

    if (isContract(_to)) {
      return transferToContract(_to, _value, _data);
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  


  function transfer(address _to, uint _value) public returns (bool success)
  {
    require(true
      && _value > 0
      && frozenAccount[msg.sender] == false
      && frozenAccount[_to] == false
      && now > unlockUnixTime[msg.sender]
      && now > unlockUnixTime[_to]
    );

    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(_to, _value, empty);
    } else {
      return transferToAddress(_to, _value, empty);
    }
  }

  


  function isContract(address _address) private view returns (bool is_contract)
  {
    uint length;
    assembly {
      
      length := extcodesize(_address)
    }
    return (length > 0);
  }

  


  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success)
  {
    if (balanceOf(msg.sender) < _value) {
      revert();
    }
    balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
    balances[_to] = SafeMath.add(balanceOf(_to), _value);
    Transfer(msg.sender, _to, _value, _data);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  


  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success)
  {
    if (balanceOf(msg.sender) < _value) {
      revert();
    }
    balances[msg.sender] = SafeMath.sub(balanceOf(msg.sender), _value);
    balances[_to] = SafeMath.add(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function burn(address _from, uint256 _amount) signed public
  {
    require(true
      && _amount > 0
      && balances[_from] >= _amount
    );

    _amount = SafeMath.mul(_amount, dec);
    balances[_from] = SafeMath.sub(balances[_from], _amount);
    totalSupply = SafeMath.sub(totalSupply, _amount);
    Burn(_from, _amount);
  }

  modifier canMint()
  {
    require(!mintingFinished);
    _;
  }

  




  function mint(address _to, uint256 _amount) signed canMint public returns (bool)
  {
    require(_amount > 0);

    _amount = SafeMath.mul(_amount, dec);
    totalSupply = SafeMath.add(totalSupply, _amount);
    balances[_to] = SafeMath.add(balances[_to], _amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  


  function finishMinting() signed canMint public returns (bool)
  {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  


  function distributeAirdrop(address[] _addresses, uint256 _amount) public returns (bool)
  {
    require(true
      && _amount > 0
      && _addresses.length > 0
      && frozenAccount[msg.sender] == false
      && now > unlockUnixTime[msg.sender]
    );

    _amount = SafeMath.mul(_amount, dec);
    uint256 totalAmount = SafeMath.mul(_amount, _addresses.length);
    require(balances[msg.sender] >= totalAmount);

    for (uint i = 0; i < _addresses.length; i++) {
      require(true
        && _addresses[i] != 0x0
        && frozenAccount[_addresses[i]] == false
        && now > unlockUnixTime[_addresses[i]]
      );

      balances[_addresses[i]] = SafeMath.add(balances[_addresses[i]], _amount);
      Transfer(msg.sender, _addresses[i], _amount);
    }
    balances[msg.sender] = SafeMath.sub(balances[msg.sender], totalAmount);
    return true;
  }

  


  function collectTokens(address[] _addresses, uint256[] _amounts) signed public returns (bool)
  {
    require(true
      && _addresses.length > 0
      && _addresses.length == _amounts.length
    );

    uint256 totalAmount = 0;

    for (uint i = 0; i < _addresses.length; i++) {
      require(true
        && _amounts[i] > 0
        && _addresses[i] != 0x0
        && frozenAccount[_addresses[i]] == false
        && now > unlockUnixTime[_addresses[i]]
      );

      _amounts[i] = SafeMath.mul(_amounts[i], dec);
      require(balances[_addresses[i]] >= _amounts[i]);

      balances[_addresses[i]] = SafeMath.sub(balances[_addresses[i]], _amounts[i]);
      totalAmount = SafeMath.add(totalAmount, _amounts[i]);
      Transfer(_addresses[i], msg.sender, _amounts[i]);
    }
    balances[msg.sender] = SafeMath.add(balances[msg.sender], totalAmount);
    return true;
  }

  


  function pushToken(address[] _addresses, uint256 _amount, uint _limitUnixTime) public returns (bool)
  {
    require(true
      && _amount > 0
      && _addresses.length > 0
      && frozenAccount[msg.sender] == false
      && now > unlockUnixTime[msg.sender]
    );

    _amount = SafeMath.mul(_amount, dec);
    uint256 totalAmount = SafeMath.mul(_amount, _addresses.length);
    require(balances[msg.sender] >= totalAmount);

    for (uint i = 0; i < _addresses.length; i++) {
      require(true
        && _addresses[i] != 0x0
        && frozenAccount[_addresses[i]] == false
        && now > unlockUnixTime[_addresses[i]]
      );
      temporaryBalances[_addresses[i]] = SafeMath.add(temporaryBalances[_addresses[i]], _amount);
      temporaryLimitUnixTime[_addresses[i]] = _limitUnixTime;
    }
    balances[msg.sender] = SafeMath.sub(balances[msg.sender], totalAmount);
    balances[temporaryAddress] = SafeMath.add(balances[temporaryAddress], totalAmount);
    Transfer(msg.sender, temporaryAddress, totalAmount);
    return true;
  }

  


  function popToken(address _to) public returns (bool)
  {
    require(true
      && temporaryBalances[msg.sender] > 0
      && frozenAccount[msg.sender] == false
      && now > unlockUnixTime[msg.sender]
      && frozenAccount[_to] == false
      && now > unlockUnixTime[_to]
      && balances[temporaryAddress] >= temporaryBalances[msg.sender]
      && temporaryLimitUnixTime[msg.sender] > now
    );

    uint256 amount = temporaryBalances[msg.sender];

    temporaryBalances[msg.sender] = 0;
    balances[temporaryAddress] = SafeMath.sub(balances[temporaryAddress], amount);
    balances[_to] = SafeMath.add(balances[_to], amount);
    Transfer(temporaryAddress, _to, amount);
    return true;
  }


  






  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(true
        && _to != address(0)
        && _value > 0
        && balances[_from] >= _value
        && allowance[_from][msg.sender] >= _value
        && frozenAccount[_from] == false 
        && frozenAccount[_to] == false
        && now > unlockUnixTime[_from] 
        && now > unlockUnixTime[_to]);

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
      Transfer(_from, _to, _value);
      return true;
  }

  





  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  





  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowance[_owner][_spender];
  }
}





library SafeMath
{
  function mul(uint256 a, uint256 b) internal pure returns (uint256)
  {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256)
  {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




