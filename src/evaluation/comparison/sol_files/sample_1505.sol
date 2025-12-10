pragma solidity ^0.8.0;
function withdraw_user21() public {
require(now > lockTime_user21[msg.sender]);
uint transferValue_user21 = 10;
msg.sender.transfer(transferValue_user21);
}