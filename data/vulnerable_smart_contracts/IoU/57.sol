contract RewardPool {
 uint256 public totalRewards;

 function addReward(uint256 _reward) external {
 totalRewards += _reward;
 }
}