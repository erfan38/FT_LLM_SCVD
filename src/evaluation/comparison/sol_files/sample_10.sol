pragma solidity ^0.8.0;
function withdraw_17() public {
require(now > lockTime_17[msg.sender]);
uint transferValue_17 = 10;
msg.sender.transfer(transferValue_17);
}