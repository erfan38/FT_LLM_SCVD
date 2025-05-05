contract BlockReward {
 uint256 public lastRewardBlock;
 uint256 public constant REWARD_INTERVAL = 100;

 function claimReward() public {
 require(block.number >= lastRewardBlock + REWARD_INTERVAL, "Wait for next reward block");
 lastRewardBlock = block.number;
 // Reward distribution logic here
 }
}