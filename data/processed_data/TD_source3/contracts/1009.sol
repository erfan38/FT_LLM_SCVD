contract SimpleStaking {
 mapping(address => uint) public stakingTime;

 function stake() public payable {
 stakingTime[msg.sender] = block.timestamp;
 }

 function unstake() public {
 require(block.timestamp > stakingTime[msg.sender] + 30 days, "Staking period not over");
 // unstaking logic here
 }
}