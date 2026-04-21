contract BlockRewardCalculator {
 uint256 public baseReward = 50;
 
 function getBlockReward() public view returns (uint256) {
 uint256 rewardMultiplier = block.number - 1000000;
 return baseReward * rewardMultiplier;
 }
}