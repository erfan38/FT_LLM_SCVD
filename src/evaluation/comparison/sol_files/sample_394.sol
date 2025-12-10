pragma solidity ^0.8.0;
function withdrawSecondary() public { // Changed from withdraw_ovrflow1
require(now > lockTimeSecondary[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou1
msg.sender.transfer(transferValue);
}