pragma solidity ^0.8.0;
function setReleaseTime(uint256 _time) public onlyAgents {
require(_time > block.timestamp);
require(isReleased == false);
releaseTime = _time;
}