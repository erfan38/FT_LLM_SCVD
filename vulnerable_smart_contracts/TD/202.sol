contract TimeLock {
 mapping(address => uint256) public lockTime;

 function lock() public payable {
 lockTime[msg.sender] = block.timestamp + 1 weeks;
 }

 function unlock() public {
 require(block.timestamp > lockTime[msg.sender], "Still locked");
 // Withdrawal logic
 }
}