contract LockupPeriod {
 uint256 public lockTime;
 uint256 public constant LOCK_DURATION = 365 days;

 function lock() public {
 lockTime = block.timestamp + LOCK_DURATION;
 }
}