pragma solidity ^0.8.0;
uint256 public nextListingId;
address winner_address7;
function play_address7(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_address7 = msg.sender;}}