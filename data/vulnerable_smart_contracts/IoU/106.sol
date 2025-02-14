contract MiningRewards {

 mapping(address => uint256) public rewardLimits;

 function computeMiningReward(uint256 miningStart) public view returns(uint256){
 uint256 reward = block.timestamp - miningStart;

 if(reward > rewardLimits[msg.sender]){
 reward = rewardLimits[msg.sender];
 }
 return reward;
 }
}