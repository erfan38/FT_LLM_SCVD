contract PricingStrategy {

  address public tier;

  
  function isPricingStrategy() public constant returns (bool) {
    return true;
  }

  
  function isSane(address crowdsale) public constant returns (bool) {
    return true;
  }

  
  function isPresalePurchase(address purchaser) public constant returns (bool) {
    return false;
  }

  
  function updateRate(uint newOneTokenInWei) public;

  
  function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}






library SafeMathLibExt {

  function times(uint a, uint b) returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function divides(uint a, uint b) returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function minus(uint a, uint b) returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function plus(uint a, uint b) returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }

}




