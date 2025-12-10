pragma solidity ^0.8.0;
function withdrawFifth() public { // Changed from withdraw_intou25
require(now > lockTimeFifth[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou25
msg.sender.transfer(transferValue);
}