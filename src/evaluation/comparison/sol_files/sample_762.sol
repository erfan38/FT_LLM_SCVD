pragma solidity ^0.8.0;
address winner_30;
function play_30(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_30 = msg.sender;}}