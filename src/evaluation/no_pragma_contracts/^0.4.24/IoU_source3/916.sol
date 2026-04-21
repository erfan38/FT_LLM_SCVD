contract TimeLock {
 uint256 public lockDuration = 30 days;
 
 function getUnlockTime(uint256 lockTime) public view returns (uint256) {
 return lockTime + lockDuration;
 }
}