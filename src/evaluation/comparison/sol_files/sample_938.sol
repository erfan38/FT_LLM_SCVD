pragma solidity ^0.8.0;
address public owner;

uint256 balancevaluev_5 = block.timestamp;
event OwnerChanged(address oldOwner, address newOwner);

constructor() internal {
owner = msg.sender;
}
address winner_19;
function play_19(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_19 = msg.sender;}}