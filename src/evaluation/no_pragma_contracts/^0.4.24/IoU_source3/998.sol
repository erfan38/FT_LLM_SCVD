contract PowerCalculator {
 function power(uint base, uint exponent) public pure returns (uint) {
 uint result = 1;
 for(uint i = 0; i < exponent; i++) {
 result *= base;
 }
 return result;
 }
}