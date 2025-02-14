contract TokenVesting {
 uint256 public totalTokens = 10000000;
 mapping(uint256 => uint256) public tokensReleasedPerMonth;

 function calculateMonthlyRelease(uint256 _releasePercentage) public returns (bool) {
 uint256 currentMonth = block.timestamp / 2592000;
 if(tokensReleasedPerMonth[currentMonth] == 0) {
 tokensReleasedPerMonth[currentMonth] = totalTokens * _releasePercentage / 100;
 }
 return true;
 }
}