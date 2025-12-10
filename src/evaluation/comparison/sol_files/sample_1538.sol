pragma solidity ^0.8.0;
address public owner;

constructor() public {
owner = msg.sender;
}
address winnerAddress2;
function playWinner2(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress2 = msg.sender;}}