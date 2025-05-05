contract TimeLock {
 mapping(address => uint256) public lockTime;
 uint256 public constant LOCK_DURATION = 1 weeks;

 function lock() public {
 lockTime[msg.sender] = block.timestamp + LOCK_DURATION;
 }
}