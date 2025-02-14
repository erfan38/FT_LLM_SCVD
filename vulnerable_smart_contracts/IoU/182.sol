contract InflationControl {
 uint256 public totalSupply = 1000000000;
 mapping(uint256 => uint256) public inflationPerYear;

 function setYearlyInflation(uint256 _inflationRate) public returns (bool) {
 uint256 currentYear = (block.timestamp / 31536000) + 1970;
 if(inflationPerYear[currentYear] == 0) {
 inflationPerYear[currentYear] = totalSupply * _inflationRate / 10000;
 }
 return true;
 }
}