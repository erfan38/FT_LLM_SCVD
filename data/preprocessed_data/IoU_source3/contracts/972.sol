contract PercentageCalculator {
 function calculatePercentage(uint _total, uint _percent) public pure returns (uint) {
 uint result = (_total * _percent) / 100;
 return result;
 }
}