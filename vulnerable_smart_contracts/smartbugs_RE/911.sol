pragma solidity ^0.4.9;

 


 
contract Axo is ERC223, SafeMath {

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  
  
  function name() public view returns (string _name) {
      return name;
  }
  
  function symbol() public view returns (string _symbol) {
      return symbol;
  }
  
  function decimals() public view returns (uint8 _decimals) {
      return decimals;
  }
  
  function totalSupply() public view returns (uint256 _totalSupply) {
      return totalSupply;
  }
  
  function Axo() public {
	  name = "axor";
	  symbol = "axo";
	  decimals = 18;
	  
	  uint256 totalUnits = 1000000000;
	  totalSupply = totalUnits * (10 ** uint256(decimals));
	  address genesis = 0xb2B34Ba2fddaC30B747cf45C2457a37c126288E4;
	  balances[genesis] = totalSupply;
  }
  
  
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
      
    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
        Transfer(msg.sender, _to, _value, _data);
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
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }


  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}