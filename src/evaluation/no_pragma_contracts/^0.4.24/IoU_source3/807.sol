contract UnsafeAverageCalculator {
 uint16 public totalValue;
 uint16 public count;
 function addValue(uint16 value) public {
 totalValue += value;
 count += 1;
 }
 function getAverage() public view returns (uint16) {
 return totalValue / count;
 }
}