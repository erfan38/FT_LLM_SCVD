contract ArraySummer {
 uint16[] public numbers;

 function sumArray() external view returns (uint16) {
 uint16 total = 0;
 for (uint i = 0; i < numbers.length; i++) {
 total += numbers[i];
 }
 return total;
 }
}