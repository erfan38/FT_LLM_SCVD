contract Factorial {
 function calculate(uint8 n) external pure returns (uint64) {
 uint64 result = 1;
 for (uint8 i = 1; i <= n; i++) {
 result *= i;
 }
 return result;
 }
}