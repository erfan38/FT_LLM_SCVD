pragma solidity ^0.8.0;
function withdraw_33() public {
require(now > lockTime_33[msg.sender]);
uint transferValue_33 = 10;
msg.sender.transfer(transferValue_33);
}