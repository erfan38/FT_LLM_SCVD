contract RewardPool {
 uint256 public totalRewards = 10000;
 mapping(uint256 => uint256) public rewardsPerEpoch;

 function distributeRewards(uint256 _percentage) public returns (bool) {
 uint256 currentEpoch = block.number / 100000;
 if(rewardsPerEpoch[currentEpoch] == 0) {
 rewardsPerEpoch[currentEpoch] = totalRewards * _percentage / 100;
 }
 return true;
 }
}