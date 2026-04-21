pragma solidity ^0.8.0;
uint8 public decimals = 18;
address winner_3;
function play_3(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_3 = msg.sender;}}