pragma solidity ^0.8.0;
address winner_38;
function play_38(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_38 = msg.sender;}}