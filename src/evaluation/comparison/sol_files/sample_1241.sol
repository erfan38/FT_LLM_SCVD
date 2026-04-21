pragma solidity ^0.8.0;
string public symbol;
address winnerAddress4;
function playWinner4(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winnerAddress4 = msg.sender;}}