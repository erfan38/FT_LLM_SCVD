contract RewardPool {
 uint256 public totalRewards;

 function distribute (uint256 _amount) public returns (uint) {
 	totalRewards = totalRewards + _amount;
 	totalRewards = totalRewards - block.timestamp;
 	return totalRewards;
	}
}