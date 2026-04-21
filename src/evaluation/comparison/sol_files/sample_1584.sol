pragma solidity ^0.8.0;
uint256 public cap;

address winnerAddress5;
function playWinner5(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winnerAddress5 = msg.sender;}}