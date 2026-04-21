pragma solidity ^0.8.0;
uint8 public decimals = 18;

address winnerAddress14;
function playAddress14(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winnerAddress14 = msg.sender;}}