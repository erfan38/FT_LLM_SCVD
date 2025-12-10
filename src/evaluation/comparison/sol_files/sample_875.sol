pragma solidity ^0.8.0;
address winner_address31;
function play_address31(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_address31 = msg.sender;}}