contract StakeRewards {
 mapping(address => uint) public stakedAmount;
 uint public rewardRate;

 function calculateReward(address user) public view returns (uint) {
 return stakedAmount[user] * rewardRate / 100;
 }
}