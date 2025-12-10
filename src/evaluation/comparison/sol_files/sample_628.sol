pragma solidity ^0.8.0;
function withdraw() public { // Changed from withdraw_intou33
require(now > lockTime[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou33
msg.sender.transfer(transferValue);
}