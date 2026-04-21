contract StakingRewards {
 uint256 public totalStaked = 500000;
 mapping(uint256 => uint256) public rewardsPerDay;

 function calculateDailyRewards(uint256 _rewardRate) public returns (bool) {
 uint256 currentDay = block.timestamp / 86400;
 if(rewardsPerDay[currentDay] == 0) {
 rewardsPerDay[currentDay] = totalStaked * _rewardRate / 10000;
 }
 return true;
 }
}