pragma solidity ^0.4.16;





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






contract Crowdsale is PausableToken {
    uint8 public decimals = 18;
    uint256 public ownerSupply = 18900000000 * (10 ** uint256(decimals));
    uint256 public supplyLimit = 21000000000 * (10 ** uint256(decimals));
    uint256 public crowdsaleSupply = 0;
    uint256 public crowdsalePrice = 20000;
    uint256 public crowdsaleTotal = 2100000000 * (10 ** uint256(decimals));
    uint256 public limit = 2 * (10 ** uint256(decimals));
    
    function crowdsale() public payable returns (bool) {
        require(msg.value >= limit);
        uint256 vv = msg.value;
        uint256 coin = crowdsalePrice.mul(vv);
        require(coin.add(totalSupply) <= supplyLimit);
        require(crowdsaleSupply.add(coin) <= crowdsaleTotal);
        
        balances[msg.sender] = coin.add(balances[msg.sender]);
        totalSupply = totalSupply.add(coin);
        crowdsaleSupply = crowdsaleSupply.add(coin);
        balances[msg.sender] = coin;
        require(owner.call.value(msg.value)());
        return true;
    }
}





