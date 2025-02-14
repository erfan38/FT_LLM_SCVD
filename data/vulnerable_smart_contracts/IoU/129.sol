contract DecreasingRewardSystem {
 uint256 public startingReward = 1000;
 
 function getCurrentReward() public view returns (uint256) {
 uint256 rewardReduction = block.number - 100;
 return startingReward - rewardReduction;
 }
}