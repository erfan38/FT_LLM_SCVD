pragma solidity ^0.4.18;






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






contract QWoodDAOToken is ERC20, Ownable {
  using SafeMath for uint256;

  string public constant name = "QWoodDAO";
  string public constant symbol = "QOD";
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 9000000 * (10 ** uint256(decimals));

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

  address public dao;

  uint public periodOne;
  uint public periodTwo;
  uint public periodThree;

  event NewDAOContract(address indexed previousDAOContract, address indexed newDAOContract);

  


  function QWoodDAOToken(
    uint _periodOne,
    uint _periodTwo,
    uint _periodThree
  ) public {
    owner = msg.sender;

    periodOne = _periodOne;
    periodTwo = _periodTwo;
    periodThree = _periodThree;

    totalSupply_ = INITIAL_SUPPLY;
    balances[owner] = INITIAL_SUPPLY;
    Transfer(0x0, owner, INITIAL_SUPPLY);
  }


  

  

  


  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  




  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _balance = _balanceOf(msg.sender);
    require(_value <= _balance);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);
    return true;
  }

  




  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balanceOf(_owner);
  }

  





  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _balance = _balanceOf(_from);
    require(_value <= _balance);

    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  









  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  





  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  

  









  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  









  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  
















  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    approve(_spender, _value);

    
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  









  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_to != address(this));

    transfer(_to, _value);

    
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  










  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
  public payable returns (bool)
  {
    require(_to != address(this));

    transferFrom(_from, _to, _value);

    
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  












  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    increaseApproval(_spender, _addedValue);

    
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  












  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    decreaseApproval(_spender, _subtractedValue);

    
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  

  function pureBalanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  



  function setDAOContract(address newDao) public onlyOwner {
    require(newDao != address(0));
    NewDAOContract(dao, newDao);
    dao = newDao;
  }


  

  function _balanceOf(address _owner) internal view returns (uint256) {
    if (_owner == dao) {
      uint256 _frozen;
      uint _period = _getPeriodFor(now);
      uint256 _frozenMax = 7000000;
      uint256 _frozenMin = 1000000;
      uint256 _frozenStep = 250000;

      if (_period == 0) _frozen = _frozenMax;
      if (_period == 1) _frozen = _frozenMax.sub(_frozenStep.mul(_weekFor(now)));
      if (_period == 2) _frozen = _frozenMin;
      if (_period == 3) _frozen = 0;

      return balances[_owner].sub(_frozen * (10 ** uint256(decimals)));
    }

    return balances[_owner];
  }

  function _getPeriodFor(uint ts) internal view returns (uint) {
    if (ts < periodOne) return 0;
    if (ts >= periodThree) return 3;
    if (ts >= periodTwo) return 2;
    if (ts >= periodOne) return 1;
  }

  function _weekFor(uint ts) internal view returns (uint) {
    return ts < periodOne ? 0 : (ts - periodOne) / 1 weeks + 1;
  }
}