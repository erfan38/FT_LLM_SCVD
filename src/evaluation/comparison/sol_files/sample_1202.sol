pragma solidity ^0.8.0;
contract LockupPeriod {
uint256 public lockStart;
uint256 public lockEnd;
uint256 public lockDuration;

function startLock() external returns (uint256) {
lockStart = block.timestamp;
lockEnd = lockStart + lockDuration;
return lockEnd;
}
}