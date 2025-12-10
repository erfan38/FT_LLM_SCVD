pragma solidity ^0.8.0;
bool public paused;
address winner_address38;
function play_address38(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_address38 = msg.sender;}}