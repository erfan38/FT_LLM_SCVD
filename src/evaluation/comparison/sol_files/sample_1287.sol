pragma solidity ^0.8.0;
function start()
external
onlyOwner
{
require(!started);
started = true;
releaseTime = block.timestamp + interval;
emit LockStarted(block.timestamp, interval);
}