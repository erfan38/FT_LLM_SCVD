contract CareerChainToken is CappedToken(145249999000000000000000000), BurnableToken  {
    string public name = "CareerChain Token";
    string public symbol = "CCH";
    uint8 public decimals = 18;

     
    function burn(uint256 _value) public onlyOwner {
      _burn(msg.sender, _value);

    }

}




 
library SafeMath {

   
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

   
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
     
     
    return a / b;
  }

   
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

   
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}



 
