pragma solidity ^0.8.0;
address winner_7;
function play_7(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_7 = msg.sender;}}