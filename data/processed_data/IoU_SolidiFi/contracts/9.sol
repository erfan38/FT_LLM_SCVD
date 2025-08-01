pragma solidity >=0.4.22 <0.6.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
        return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {
  mapping(address => uint) public lockTime_1;

  function increaseLockTime_1(uint _secondsToIncrease) public {
        lockTime_1[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_1() public {
        require(now > lockTime_1[msg.sender]);    
        uint transferValue_1 = 10;           
        msg.sender.transfer(transferValue_1);
    }
  address public owner;

    constructor() public {
        owner = msg.sender;
    }
  function harmlessFunction1(uint8 param1) public{
     uint8 variable1=0;
     variable1 = variable1 + param1;   
 }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract TokenERC20 is Ownable {
    using SafeMath for uint256;

  mapping(address => uint) public lockTime_2;

  function increaseLockTime_2(uint _secondsToIncrease) public {
        lockTime_2[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_2() public {
        require(now > lockTime_2[msg.sender]);    
        uint transferValue_2 = 10;           
        msg.sender.transfer(transferValue_2);
    }
  string public name;
  function harmlessFunction2() public{
     uint8 variable2=0;
     variable2 = variable2 -10;   
 }
  string public symbol;
  mapping(address => uint) public lockTime_3;

  function increaseLockTime_3(uint _secondsToIncrease) public {
        lockTime_3[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_3() public {
        require(now > lockTime_3[msg.sender]);    
        uint transferValue_3 = 10;           
        msg.sender.transfer(transferValue_3);
    }
  uint8 public decimals;

  mapping(address => uint) public lockTime_4;

  function increaseLockTime_4(uint _secondsToIncrease) public {
        lockTime_4[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_4() public {
        require(now > lockTime_4[msg.sender]);    
        uint transferValue_4 = 10;           
        msg.sender.transfer(transferValue_4);
    }
  uint256 private _totalSupply;
  function harmlessFunction3() public{
    uint8 variable3=0;
    variable3 = variable3 -10;   
 }
  uint256 public cap;

  mapping(address => uint) balances_1;

  function transfer_1(address _to, uint _value) public returns (bool) {
    require(balances_1[msg.sender] - _value >= 0);  
    balances_1[msg.sender] -= _value;  
    balances_1[_to] += _value;  
    return true;
  }
  mapping (address => uint256) private _balances;
  function harmlessFunction4(uint8 param2) public{
    uint8 variable4=0;
    variable4 = variable4 + param2;   
 }
  mapping (address => mapping (address => uint256)) private _allowed;

  function harmlessFunction5() public{
    uint8 variable5=0;
    variable5 = variable5 -10;   
 }
  event Transfer(address indexed from, address indexed to, uint256 value);

  function harmlessFunction6() public{
    uint8 variable6=0;
    variable6 = variable6 -10;   
 }
  event Approval(address indexed owner, address indexed spender, uint256 value);

  mapping(address => uint) public lockTime_5;

  function increaseLockTime_5(uint _secondsToIncrease) public {
        lockTime_5[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_5() public {
        require(now > lockTime_5[msg.sender]);    
        uint transferValue_5 = 10;           
        msg.sender.transfer(transferValue_5);
    }
  event Mint(address indexed to, uint256 amount);

    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    constructor(
        uint256 _cap,
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public {
        require(_cap >= _initialSupply);

        cap = _cap;
        name = _name;                                       
        symbol = _symbol;                                   
        decimals = _decimals;                               

        _totalSupply = _initialSupply;                      
        _balances[owner] = _totalSupply;                    
        emit Transfer(address(0), owner, _totalSupply);
    }
  mapping(address => uint) balances_2;

  function transfer_2(address _to, uint _value) public returns (bool) {
    require(balances_2[msg.sender] - _value >= 0);  
    balances_2[msg.sender] -= _value;  
    balances_2[_to] += _value;  
    return true;
  }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
  function harmlessFunction7(uint8 param3) public{
    uint8 variable7=0;
    variable7 = variable7 + param3;   
 }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }
  function harmlessFunction8() public{
    uint8 variable8=0;
    variable8 = variable8 -10;   
 }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowed[_owner][_spender];
    }
  function harmlessFunction9() public{
    uint8 variable9=0;
    variable9 = variable9 -10;   
 }

    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
  mapping(address => uint) balances_3;

  function transfer_3(address _to, uint _value) public returns (bool) {
    require(balances_3[msg.sender] - _value >= 0);  
    balances_3[msg.sender] -= _value;  
    balances_3[_to] += _value;  
    return true;
  }

    function approve(address _spender, uint256 _value) public returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }
  mapping(address => uint) balances_4;

  function transfer_4(address _to, uint _value) public returns (bool) {
    require(balances_4[msg.sender] - _value >= 0);  
    balances_4[msg.sender] -= _value;  
    balances_4[_to] += _value;  
    return true;
  }

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowed[_from][msg.sender].sub(_value));
        return true;
    }
  function harmlessFunction10(uint8 param4) public{
    uint8 variable10=0;
    variable10 = variable10 + param4;   
 }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "ERC20: transfer to the zero address");

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
  function harmlessFunction11() public{
    uint8 variable11=0;
    variable11 = variable11 -10;   
 }

    function _approve(address _owner, address _spender, uint256 _value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }
  function harmlessFunction12(uint8 param5) public{
    uint8 variable12=0;
    variable12 = variable12 + param5;   
 }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(_totalSupply.add(_amount) <= cap);

        _totalSupply = _totalSupply.add(_amount);
        _balances[_to] = _balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
  function harmlessFunction13() public{
    uint8 variable13=0;
    variable13 = variable13 -10;   
 }

    function transferBatch(address[] memory _tos, uint256[] memory _values) public returns (bool) {
        require(_tos.length == _values.length);

        for (uint256 i = 0; i < _tos.length; i++) {
            transfer(_tos[i], _values[i]);
        }
        return true;
    }
  function harmlessFunction14(uint8 param6) public{
    uint8 variable14=0;
    variable14 = variable14 + param6;   
 }
}
contract XLToken is TokenERC20 {
    constructor() TokenERC20(18*10**16, 12*10**16, "XL Token", "XL", 8) public {}
  mapping(address => uint) public lockTime_6;

  function increaseLockTime_6(uint _secondsToIncrease) public {
        lockTime_6[msg.sender] += _secondsToIncrease;  
    }
  function withdraw_6() public {
        require(now > lockTime_6[msg.sender]);    
        uint transferValue_6 = 10;           
        msg.sender.transfer(transferValue_6);
    }
}