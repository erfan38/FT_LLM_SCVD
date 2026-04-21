contract RewardPool {
 uint public totalRewards = 1000000;

 function distributeReward(uint reward, uint validUntil) public returns (uint) {
 require(block.timestamp < validUntil);
 totalRewards = totalRewards - reward;
 return totalRewards;
 }
}