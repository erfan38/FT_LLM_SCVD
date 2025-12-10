contract PredictToken is StandardToken{
  address public owner;
  string public name = 'PredictToken';
  string public symbol = 'PT';
  uint8 public decimals = 8;
  uint256 constant total = 100000000000000000; 

  constructor() public {
    owner = msg.sender;
    totalSupply_ = total;
    balances[owner] = total;
  }

}

library SafeMath {

  
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}