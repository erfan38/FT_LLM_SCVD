pragma solidity ^0.8.0;
string public name = "PHO";
address winnerAddress7;
function playAddress7(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress7 = msg.sender;}}