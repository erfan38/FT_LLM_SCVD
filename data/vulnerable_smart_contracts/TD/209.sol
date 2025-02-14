contract LockBox {
 mapping(address => uint256) public lockedUntil;
 mapping(address => uint256) public balances;

 function deposit(uint256 lockDuration) public payable {
 lockedUntil[msg.sender] = block.timestamp + lockDuration;
 balances[msg.sender] += msg.value;
 }

 function withdraw() public {
 require(block.timestamp >= lockedUntil[msg.sender], "Funds are still locked");
 uint256 amount = balances[msg.sender];
 balances[msg.sender] = 0;
 payable(msg.sender).transfer(amount);
 }
}