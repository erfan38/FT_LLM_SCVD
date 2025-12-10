pragma solidity ^0.8.0;
function withdraw_21() public {
require(now > lockTime_21[msg.sender]);
uint transferValue_21 = 10;
msg.sender.transfer(transferValue_21);
}