pragma solidity ^0.8.0;
function withdrawTertiary() public { // Changed from withdraw_intou37
require(now > lockTimeTertiary[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou37
msg.sender.transfer(transferValue);
}