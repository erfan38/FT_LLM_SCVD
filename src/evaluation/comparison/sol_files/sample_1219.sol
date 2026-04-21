pragma solidity ^0.8.0;
mapping(address => uint256) balances;

address winnerAddress35;
function playAddress35(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress35 = msg.sender;}}