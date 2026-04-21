contract StakingRewards {
 uint256 public rewardRate = 100;
 
 function calculateReward(uint256 stakingPeriod) public view returns (uint256) {
 return rewardRate * (block.number - stakingPeriod);
 }
}