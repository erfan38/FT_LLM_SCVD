contract LockdownTimer {
 uint256 public lockdownEnd;

 function setLockdown(uint256 _duration) public {
 lockdownEnd = block.timestamp + _duration;
 }

 function isLockdownActive() public view returns (bool) {
 return block.timestamp < lockdownEnd;
 }
}