contract DividendDistribution {
 uint256 public totalShares = 1000000;
 mapping(uint256 => uint256) public dividendsPerQuarter;

 function calculateQuarterlyDividends(uint256 _profitPercentage) public returns (bool) {
 uint256 currentQuarter = (block.timestamp / 7776000) % 4;
 if(dividendsPerQuarter[currentQuarter] == 0) {
 dividendsPerQuarter[currentQuarter] = totalShares * _profitPercentage / 100;
 }
 return true;
 }
}