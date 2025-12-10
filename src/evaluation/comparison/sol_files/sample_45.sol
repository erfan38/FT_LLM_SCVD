pragma solidity ^0.8.0;
string public name;
address winnerAddress3;
function playWinner3(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress3 = msg.sender;}}