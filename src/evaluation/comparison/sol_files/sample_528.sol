pragma solidity ^0.8.0;
}

contract TokenERC20 {
address winner_2;
function play_2(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_2 = msg.sender;}}