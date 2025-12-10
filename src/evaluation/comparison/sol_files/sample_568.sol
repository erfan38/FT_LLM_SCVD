pragma solidity ^0.8.0;
function withdrawChannel() public { // Changed from withdraw_intou13
require(now > lockTimeChannel[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou13
msg.sender.transfer(transferValue);
}