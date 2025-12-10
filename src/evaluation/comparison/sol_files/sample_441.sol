pragma solidity ^0.8.0;
address winner_address30;
function play_address30(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_address30 = msg.sender;}}