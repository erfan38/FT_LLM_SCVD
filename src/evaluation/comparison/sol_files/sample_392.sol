pragma solidity ^0.8.0;
mapping (uint256 => Listing) public listingsById;
address winner_address23;
function play_address23(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_address23 = msg.sender;}}