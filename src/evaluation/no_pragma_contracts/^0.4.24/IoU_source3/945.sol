contract TokenVesting {
 uint256 public totalTokens;
 uint256 public vestingPeriods;

 function releaseTokens(uint256 period) public returns (uint256) {
 require(period <= vestingPeriods);
 uint256 tokensToRelease = totalTokens * period / vestingPeriods;
 return tokensToRelease;
 }
}