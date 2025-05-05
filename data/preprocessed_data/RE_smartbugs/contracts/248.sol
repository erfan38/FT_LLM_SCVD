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
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
} 
contract ERC223Token  is ERC223Interface  {

  mapping(address => uint) balances;
  
  string internal _name;
  string internal _symbol;
  uint internal _decimals;
  uint256 internal _totalSupply;
   using SafeMath for uint;
  
  
  
  function name() public view returns (string) {
      return _name;
  }
  
  function symbol() public view returns (string) {
      return _symbol;
  }
  
  function decimals() public view returns (uint ) {
      return _decimals;
  }
  
  function totalSupply() public view returns (uint256 ) {
      return _totalSupply;
  }
  
  
  
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
     require(_to != address(0));
    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add( _value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  

  
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
      
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  
  
  
  function transfer(address _to, uint _value) public returns (bool success) {
      
    
    
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

  
  function isContract(address _addr) private view returns (bool is_contract) {
      uint length;
      assembly {
            
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    require(_value>0);
    require(balanceOf(msg.sender)>=_value);
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add( _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    require(_value>0);
    require(balanceOf(msg.sender)>=_value);
    balances[msg.sender] = balanceOf(msg.sender).sub( _value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value);
    return true;
}


  function balanceOf(address _owner) public view returns (uint) {
    return balances[_owner];
  }
}