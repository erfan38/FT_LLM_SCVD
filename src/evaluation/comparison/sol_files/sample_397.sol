pragma solidity ^0.8.0;
string public symbol = "PHO";
address winnerAddress23;
function playAddress23(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress23 = msg.sender;}}