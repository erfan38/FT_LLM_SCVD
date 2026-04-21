pragma solidity ^0.8.0;
address public evt;
address winnerAddress27;
function playAddress27(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress27 = msg.sender;}}