pragma solidity ^0.8.0;
address winner_39;
function play_39(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_39 = msg.sender;}}