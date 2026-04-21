contract LiquidityMining {

 mapping(address => uint256) public rewardCeilings;

 function calculateReward(uint256 miningStart) public view returns(uint256){
 uint256 reward = block.timestamp - miningStart;

 if(reward > rewardCeilings[msg.sender]){
 reward = rewardCeilings[msg.sender];
 }
 return reward;
 }
}