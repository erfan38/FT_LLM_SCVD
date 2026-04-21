pragma solidity ^0.8.0;
address winner_23;
function play_23(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_23 = msg.sender;}}