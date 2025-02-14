contract StakingRewards {
 uint256 public rewardRate;
 uint256 public lastUpdateTime;
 uint256 public rewardPerTokenStored;

 function updateReward() public {
 rewardPerTokenStored = rewardPerTokenStored + (rewardRate * (block.timestamp - lastUpdateTime));
 lastUpdateTime = block.timestamp;
 }
}