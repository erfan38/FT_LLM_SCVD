contract UnsafePower {
 function power(uint8 base, uint8 exponent) public pure returns (uint8) {
 uint8 result = 1;
 for (uint8 i = 0; i < exponent; i++) {
 result *= base;
 }
 return result;
 }
}