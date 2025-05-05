contract UnsafeLoop {
 function sumTo(uint8 n) public pure returns (uint8) {
 uint8 sum = 0;
 for (uint8 i = 1; i <= n; i++) {
 sum += i;
 }
 return sum;
 }
}