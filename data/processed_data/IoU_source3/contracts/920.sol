contract RewardDistributor {
 uint256 public totalRewards;
 uint256 public rewardRate;

 function distributeRewards(uint256 timePeriod) public view returns (uint256) {
 return totalRewards + (rewardRate * timePeriod);
 }
}