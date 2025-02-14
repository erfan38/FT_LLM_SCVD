pragma solidity 0.4.21;











contract ZoologicalGarden is ERC223, ERC20Basic {
  using SafeMath for uint256;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  mapping(address => uint256) public balances;

  



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

  




  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return balances[_owner];
  }
  
  
  function ZoologicalGarden() public{
      name = "Zoological Garden";
      symbol = "ZOO";
      decimals = 4;
      totalSupply = 100000000 * 10 ** uint(decimals);
      balances[msg.sender] = totalSupply;

  }

  






  function transfer(address _to, uint256 _value, bytes _data, string _fallback) public returns (bool _success) {
    if (isContract(_to)) {
      if (balanceOf(msg.sender) < _value)
      revert();
      balances[msg.sender] = balanceOf(msg.sender).sub(_value);
      balances[_to] = balanceOf(_to).add(_value);
      
      
      
      assert(_to.call.value(0)(bytes4(keccak256(_fallback)), msg.sender, _value, _data));
      
      Transfer(msg.sender, _to, _value, _data);
      return true;
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  





  function transfer(address _to, uint256 _value, bytes _data) public returns (bool _success) {
    if (isContract(_to)) {
      return transferToContract(_to, _value, _data);
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  





  function transfer(address _to, uint256 _value) public returns (bool _success) {
    
    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(_to, _value, empty);
    } else {
      return transferToAddress(_to, _value, empty);
    }
  }

  




  function isContract(address _addr) private view returns (bool _isContract) {
    uint length;
    assembly {
      length := extcodesize(_addr)
    }
    return (length > 0);
  }
    
  





  function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool _success) {
    if (balanceOf(msg.sender) < _value)
    revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);

    Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  





  function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool _success) {
    if (balanceOf(msg.sender) < _value) {
        revert();
    }
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);

    
    
    ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
    receiver.tokenFallback(msg.sender, _value, _data);

    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
}