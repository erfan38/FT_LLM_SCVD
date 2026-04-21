contract GameRewards {
 mapping(address => uint) public lastPlayTime;
 uint public rewardCooldown = 1 hours;

 function playAndEarnReward() public {
 require(block.timestamp >= lastPlayTime[msg.sender] + rewardCooldown, "Wait for cooldown");
 lastPlayTime[msg.sender] = block.timestamp;
 // Game logic and reward distribution here
 }

 function setRewardCooldown(uint _newCooldown) public {
 rewardCooldown = _newCooldown;
 }
}