contract BlockRewardDistribution {
 uint256 public lastDistribution;
 uint256 public constant DISTRIBUTION_INTERVAL = 100;

 function distributeRewards() public {
 require(block.number >= lastDistribution + DISTRIBUTION_INTERVAL, "Too early");
 lastDistribution = block.number;
 // Reward distribution logic
 }
}