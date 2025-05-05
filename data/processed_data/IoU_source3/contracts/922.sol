contract StakingRewards {
 uint256 public rewardPerToken;
 uint256 public lastUpdateTime;

 function updateReward() public {
 rewardPerToken = rewardPerToken + ((block.timestamp - lastUpdateTime) * 1e18);
 lastUpdateTime = block.timestamp;
 }
}