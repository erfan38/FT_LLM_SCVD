contract DailyReward {
 mapping(address => uint256) public lastClaimTime;

 function claimReward() public {
 require(block.timestamp >= lastClaimTime[msg.sender] + 1 days, "Wait 24 hours between claims");
 lastClaimTime[msg.sender] = block.timestamp;
 // Transfer reward to user
 }
}