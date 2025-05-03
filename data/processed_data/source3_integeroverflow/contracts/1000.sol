contract UnsafeCalculator {
 function multiply(uint a, uint b) public pure returns (uint) {
 return a * b;
 }

 function divide(uint a, uint b) public pure returns (uint) {
 return a / b;
 }
}