pragma solidity ^0.8.0;
uint256 saleAmount;
address winnerAddress30;
function playAddress30(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winnerAddress30 = msg.sender;}}