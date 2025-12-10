pragma solidity ^0.8.0;
function withdraw_9() public {
require(now > lockTime_9[msg.sender]);
uint transferValue_9 = 10;
msg.sender.transfer(transferValue_9);
}