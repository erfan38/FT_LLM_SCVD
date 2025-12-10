contract StakingRewards {

 mapping(address => uint256) public maxRewards;

 function computeReward(uint256 stakingStart) public view returns(uint256){
 uint256 reward = block.timestamp - stakingStart;

 if(reward > maxRewards[msg.sender]){
 reward = maxRewards[msg.sender];
 }
 return reward;
 }
}