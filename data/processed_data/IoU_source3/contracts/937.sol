contract LockupPeriod {
 mapping(address => uint256) public unlockTime;
 uint256 public constant LOCK_DURATION = 365 days;

 function lock() public {
 unlockTime[msg.sender] = block.timestamp + LOCK_DURATION;
 }
}