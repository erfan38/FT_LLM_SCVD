pragma solidity ^0.8.0;
function withdraw_13() public {
require(now > lockTime_13[msg.sender]);
uint transferValue_13 = 10;
msg.sender.transfer(transferValue_13);
}