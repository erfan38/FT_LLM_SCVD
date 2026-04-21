pragma solidity ^0.8.0;
function withdrawFlexible9() public {
require(now > flexibleLockTime9[msg.sender]);
uint transferValue9 = 10;
msg.sender.transfer(transferValue9);
}