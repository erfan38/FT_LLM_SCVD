contract StakedRewards {
 mapping(address => uint256) public stakedAmount;
 mapping(address => uint256) public lastClaimTime;

 function stake() public payable {
 stakedAmount[msg.sender] += msg.value;
 lastClaimTime[msg.sender] = block.timestamp;
 }

 function claimRewards() public {
 uint256 timePassed = block.timestamp - lastClaimTime[msg.sender];
 uint256 rewards = (stakedAmount[msg.sender] * timePassed) / 1 days;
 lastClaimTime[msg.sender] = block.timestamp;
 // Transfer rewards
 }
}