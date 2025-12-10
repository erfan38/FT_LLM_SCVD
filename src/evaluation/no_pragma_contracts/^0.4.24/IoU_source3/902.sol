contract StakingRewards {
 uint256 public totalRewards;

 function claimRewards (uint256 _rewardAmount) public returns (uint) {
 	totalRewards = totalRewards - _rewardAmount;
 	totalRewards = totalRewards + block.timestamp;
 	return totalRewards;
	}
}