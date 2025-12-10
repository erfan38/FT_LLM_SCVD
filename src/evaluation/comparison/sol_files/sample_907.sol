pragma solidity ^0.8.0;
address winner_address35;
function play_address35(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_address35 = msg.sender;}}