pragma solidity ^0.8.0;
address winner_35;
function play_35(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_35 = msg.sender;}}