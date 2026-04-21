pragma solidity ^0.8.0;
address winnerAddress12;
function playWinner12(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress12 = msg.sender;}
}