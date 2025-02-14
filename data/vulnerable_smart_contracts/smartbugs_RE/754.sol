pragma solidity ^0.4.24;


contract ERC223Token is ERC223 {
  using SafeMath for uint;

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint256 public decimals;
  uint256 public totalSupply;

  modifier validDestination( address to ) {
    require(to != address(0x0));
    _;
  }
  
  
  
  function name() public view returns (string _name) {
    return name;
  }
  
  function symbol() public view returns (string _symbol) {
    return symbol;
  }
  
  function decimals() public view returns (uint256 _decimals) {
    return decimals;
  }
  
  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }
  
  
  
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) validDestination(_to) public returns (bool success) {
      
    if(isContract(_to)) {
      if (balanceOf(msg.sender) < _value) revert();
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
  

  
  function transfer(address _to, uint _value, bytes _data) validDestination(_to) public returns (bool success) {
      
    if(isContract(_to)) {
      return transferToContract(_to, _value, _data);
    }
    else {
      return transferToAddress(_to, _value, _data);
    }
  }
  
  
  
  function transfer(address _to, uint _value) validDestination(_to) public returns (bool success) {
      
    
    
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
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
}


  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

