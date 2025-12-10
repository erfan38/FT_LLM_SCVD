contract RewardCalculator {
 uint256 public baseReward = 100;
 
 function calculateReward(uint256 stakingPeriod) public view returns (uint256) {
 return baseReward * (block.number - stakingPeriod);
 }
}