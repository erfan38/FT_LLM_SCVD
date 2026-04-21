pragma solidity ^0.8.0;
function withdrawFourth() public { // Changed from withdraw_intou9
require(now > lockTimeFourth[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou9
msg.sender.transfer(transferValue);
}