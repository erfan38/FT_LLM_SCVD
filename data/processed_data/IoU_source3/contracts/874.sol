contract RewardDistributor {

 mapping(address => uint256) public rewardCaps;

 function calculateReward(uint256 startTime) public view returns(uint256){
 uint256 reward = block.timestamp - startTime;

 if(reward > rewardCaps[msg.sender]){
 reward = rewardCaps[msg.sender];
 }
 return reward;
 }
}