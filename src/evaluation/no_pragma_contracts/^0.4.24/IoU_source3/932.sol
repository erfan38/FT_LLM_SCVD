contract RewardDistributor {
 uint256 public totalRewards;
 uint256 public constant REWARD_RATE = 10;

 function distributeRewards(uint256 timePeriod) public {
 uint256 reward = REWARD_RATE * timePeriod;
 totalRewards = totalRewards + reward;
 }
}