contract LiquidityMining {
 uint256 public totalLiquidity = 1000000;
 mapping(uint256 => uint256) public rewardsPerBlock;

 function setBlockRewards(uint256 _rewardPercentage) public returns (bool) {
 uint256 currentBlock = block.number;
 if(rewardsPerBlock[currentBlock] == 0) {
 rewardsPerBlock[currentBlock] = totalLiquidity * _rewardPercentage / 1000;
 }
 return true;
 }
}