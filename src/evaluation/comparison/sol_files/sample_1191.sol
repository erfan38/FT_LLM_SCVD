pragma solidity ^0.8.0;
function withdrawFlexible25() public {
require(now > flexibleLockTime25[msg.sender]);
uint transferValue25 = 10;
msg.sender.transfer(transferValue25);
}