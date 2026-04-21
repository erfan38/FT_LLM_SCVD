pragma solidity ^0.8.0;
uint256 teamAmount;

address winnerAddress39;
function playAddress39(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress39 = msg.sender;}}