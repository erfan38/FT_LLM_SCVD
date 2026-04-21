contract HMCToken is PausableFrozenToken {
    string public name = "HMC";
    string public symbol = "HMC";
    uint8 public decimals = 18;

    function HMCToken() {
      totalSupply = 1000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;    
    }

    function () {
        revert();
    }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}