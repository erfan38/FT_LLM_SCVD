contract TimeLock {
 mapping(address => uint256) public balances;
 mapping(address => uint256) public lockTime;

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 lockTime[msg.sender] = block.timestamp + 1 weeks;
 }

 function withdraw() public {
 require(block.timestamp > lockTime[msg.sender], "Lock time not expired");
 uint256 amount = balances[msg.sender];
 balances[msg.sender] = 0;
 payable(msg.sender).transfer(amount);
 }
}