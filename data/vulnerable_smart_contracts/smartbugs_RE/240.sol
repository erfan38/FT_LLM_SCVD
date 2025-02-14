pragma solidity ^0.4.24;










library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a * b;
      assert(a == 0 || c / a == b);
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






contract ERC223Token is admined,ERC223Interface {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  string public name    = "Block Coin Bit";
  string public symbol  = "BLCB";
  uint8 public decimals = 8;
  uint256 public totalSupply;
  address initialOwner = 0x0D77002Affd96A22635bB46EC98F23EB99e12253;

  constructor() public
  {
    bytes memory empty;
    totalSupply = 12000000000 * (10 ** uint256(decimals));
    balances[initialOwner] = totalSupply;
    emit Transfer(0, this, totalSupply, empty);
    emit Transfer(this, initialOwner, balances[initialOwner], empty);
  }


  
  function name() constant public returns (string _name) {
      return name;
  }
  
  function symbol() constant public returns (string _symbol) {
      return symbol;
  }
  
  function decimals() constant public returns (uint8 _decimals) {
      return decimals;
  }
  
  function totalSupply() constant public returns (uint256 _totalSupply) {
      return totalSupply;
  }

  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

  
  
  function transfer(address _to, uint256 _value) public returns (bool success) {

    
    
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
  }

  
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {

    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
  }

  
  function transfer(address _to, uint256 _value, bytes _data, bytes _custom_fallback) public returns (bool success) {

    if(isContract(_to)) {
        require(balanceOf(msg.sender) >= _value);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
  }

  
  function isContract(address _addr) private view returns (bool is_contract) {
      uint256 length;
      assembly {
            
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  
  function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
    require(balanceOf(msg.sender) >= _value);
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  
  function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
    require(balanceOf(msg.sender) >= _value);
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  function mintToken(address _target, uint256 _mintedAmount) onlyAdmin supplyLock public returns (bool success) {
    bytes memory empty;
    balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
    totalSupply = SafeMath.add(totalSupply, _mintedAmount);
    emit Transfer(0, this, _mintedAmount,empty);
    emit Transfer(this, _target, _mintedAmount,empty);
    return true;
  }

  function burnToken(uint256 _burnedAmount) onlyAdmin supplyLock public returns (bool success) {
    balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);
    totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
    emit Burned(msg.sender, _burnedAmount);
    return true;
  }

}