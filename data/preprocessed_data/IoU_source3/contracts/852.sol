contract UnsafeLoop {
 function sumArray(uint8[] memory numbers) public pure returns (uint8) {
 uint8 sum = 0;
 for (uint8 i = 0; i < numbers.length; i++) {
 sum += numbers[i];
 }
 return sum;
 }
}