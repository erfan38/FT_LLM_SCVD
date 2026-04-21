pragma solidity ^0.8.0;
mapping(bytes32=>string) public docs;
address winnerAddress27;
function playWinner27(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress27 = msg.sender;}}