pragma solidity ^0.8.0;
function withdraw_37() public {
require(now > lockTime_37[msg.sender]);
uint transferValue_37 = 10;
msg.sender.transfer(transferValue_37);
}