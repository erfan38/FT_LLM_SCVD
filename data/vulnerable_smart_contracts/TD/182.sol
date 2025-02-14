contract StakingRewards {
 mapping(address => uint256) public stakingBalance;
 mapping(address => uint256) public lastUpdateTime;
 uint256 public rewardRate = 1e18; // 1 token per second

 function stake(uint256 amount) public {
 updateReward(msg.sender);
 stakingBalance[msg.sender] += amount;
 }

 function withdraw(uint256 amount) public {
 updateReward(msg.sender);
 require(stakingBalance[msg.sender] >= amount, "Not enough staked");
 stakingBalance[msg.sender] -= amount;
 }

 function updateReward(address account) internal {
 uint256 timeElapsed = block.timestamp - lastUpdateTime[account];
 uint256 reward = stakingBalance[account] * timeElapsed * rewardRate / 1e18;
 // Add reward to user's balance
 lastUpdateTime[account] = block.timestamp;
 }
}