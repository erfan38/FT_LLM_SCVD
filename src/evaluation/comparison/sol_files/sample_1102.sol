pragma solidity ^0.8.0;
address winnerAddress31;
function playWinner31(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress31 = msg.sender;}}