pragma solidity ^0.8.0;
address winner_27;
function play_27(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_27 = msg.sender;}}