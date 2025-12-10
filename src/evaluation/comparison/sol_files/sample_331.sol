pragma solidity ^0.8.0;
function withdraw_25() public {
require(now > lockTime_25[msg.sender]);
uint transferValue_25 = 10;
msg.sender.transfer(transferValue_25);
}