pragma solidity ^0.8.0;
Token public token;
address winner_26;
function play_26(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_26 = msg.sender;}}