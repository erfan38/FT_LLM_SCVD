pragma solidity ^0.8.0;
function withdrawFlow1() public {
require(now > lockTime_user1[msg.sender]);
uint transferValue_user1 = 10;
msg.sender.transfer(transferValue_user1);
}