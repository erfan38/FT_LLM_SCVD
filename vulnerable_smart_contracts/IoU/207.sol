contract RewardSystem {
 uint public constant POINTS_PER_LEVEL = 1000;
 mapping(address => uint) public userLevels;

 function calculateRewards(address user) public view returns (uint) {
 return userLevels[user] * POINTS_PER_LEVEL;
 }
}