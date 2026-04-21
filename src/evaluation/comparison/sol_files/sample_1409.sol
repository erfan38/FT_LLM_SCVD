pragma solidity ^0.8.0;
mapping (uint256 => Purchase) public purchasesById;
address winner_address14;
function play_address14(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_address14 = msg.sender;}}