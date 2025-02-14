contract RewardDistributor {
 uint256 public totalReward;
 uint256 public userCount;

 function distributeReward() public returns (uint256) {
 uint256 rewardPerUser = totalReward / userCount;
 return rewardPerUser;
 }
}