pragma solidity ^0.8.0;
function withdraw_1() public {
require(now > lockTime_1[msg.sender]);
uint transferValue_1 = 10;
msg.sender.transfer(transferValue_1);
}