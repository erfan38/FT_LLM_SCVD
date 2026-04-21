contract Timelock {
 uint256 public lockDuration = 365 days;

 function calculateUnlockTime(uint256 lockTime) public view returns (uint256) {
 return lockTime + lockDuration;
 }
}