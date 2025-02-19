contract TokenLock {
 mapping(address => uint256) public lockedTokens;
 mapping(address => uint256) public unlockTime;

 function lockTokens(uint256 amount, uint256 lockDuration) public {
 lockedTokens[msg.sender] += amount;
 unlockTime[msg.sender] = block.timestamp + lockDuration;
 }

 function unlockTokens() public {
 require(block.timestamp >= unlockTime[msg.sender], "Tokens are still locked");
 uint256 amount = lockedTokens[msg.sender];
 lockedTokens[msg.sender] = 0;
 // Transfer tokens back to user
 }
}