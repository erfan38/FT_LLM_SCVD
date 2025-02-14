contract SafeMultiplier {
 uint256 public result = 1;
 function multiply(uint256 factor) public {
 require(factor == 0 || result <= type(uint256).max / factor, 'Overflow detected');
 result *= factor;
 }
}