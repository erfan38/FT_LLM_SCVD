pragma solidity ^0.8.0;
}

contract Staking is Owned{
address winner_19;
function play_19(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_19 = msg.sender;}}