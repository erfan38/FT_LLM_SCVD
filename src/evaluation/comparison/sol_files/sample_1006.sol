pragma solidity ^0.8.0;
address winnerAddress7;
function playWinner7(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winnerAddress7 = msg.sender;}}