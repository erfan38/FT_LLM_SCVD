contract StakedTokens {
 mapping(address => uint256) public stakedAmount;
 mapping(address => uint256) public stakingTime;

 function stake(uint256 amount) public {
 stakedAmount[msg.sender] += amount;
 stakingTime[msg.sender] = block.timestamp;
 }

 function calculateRewards(address user) public view returns (uint256) {
 uint256 stakingDuration = block.timestamp - stakingTime[user];
 return stakedAmount[user] * stakingDuration / 1 days;
 }
}