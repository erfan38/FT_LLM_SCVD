contract UnsafeAverage {
 function average(uint256 a, uint256 b) public pure returns (uint256) {
 return (a + b) / 2;
 }
}