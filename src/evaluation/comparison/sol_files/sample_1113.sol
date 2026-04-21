pragma solidity ^0.8.0;
function lock() internal notLocked onlyOwner {

lockedAt = block.timestamp;

timeLocks[teamReserveWallet] = lockedAt.add(teamTimeLock);
timeLocks[finalReserveWallet] = lockedAt.add(finalReserveTimeLock);

Locked(lockedAt);
}