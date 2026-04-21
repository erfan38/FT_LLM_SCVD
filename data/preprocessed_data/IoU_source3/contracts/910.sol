contract TokenLockup {
 uint256 public lockupPeriod = 365 days;
 
 function getUnlockTime() public view returns (uint256) {
 return block.timestamp + lockupPeriod;
 }
}