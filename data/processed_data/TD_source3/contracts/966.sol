contract GameRewards {
 uint256 public lastRewardBlock;
 uint256 public rewardInterval = 100; // blocks

 function claimReward() public {
 require(block.number >= lastRewardBlock + rewardInterval, "Wait for next reward block");
 lastRewardBlock = block.number;
 // Distribute reward to player
 }

 function setRewardInterval(uint256 _newInterval) public {
 rewardInterval = _newInterval;
 }
}