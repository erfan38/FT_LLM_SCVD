contract StakingPool {
 uint256 public totalStaked;

 function stake (uint256 _amount) public returns (uint) {
 	totalStaked = totalStaked + _amount;
 	totalStaked = totalStaked - block.timestamp;
 	return totalStaked;
	}
}