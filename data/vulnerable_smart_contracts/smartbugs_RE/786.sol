pragma solidity ^0.4.23;


contract PiperToken is ERC223, SafeMath {

  mapping(address => uint) balances;
  
  string public name = "Peid Piper Token";
  string public symbol = "PIP";
  uint8 public decimals = 18;
  uint256 public totalSupply = 0;
  uint256 exchange = 1000000;
  uint256 endICO = 0;
  address admin;
  
  constructor() public {
      balances[msg.sender]=1000000000000000000000000;
      admin = msg.sender;
      
      endICO=block.timestamp+(60*60*24*31); 
  }
  
  
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
  
  function () public payable{
      
      if(block.timestamp>endICO)revert("ICO OVER");
      balances[msg.sender]=safeAdd(balances[msg.sender],safeMul(msg.value,exchange));
      totalSupply=safeAdd(totalSupply,safeMul(msg.value,exchange)); 
      admin.transfer(address(this).balance);
  }
  
  function getEndICO() public constant returns (uint256){
      return endICO;
  }
  
  function getCurrentTime() public constant returns (uint256){
      return block.timestamp;
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