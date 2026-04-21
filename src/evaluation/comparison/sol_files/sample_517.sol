pragma solidity ^0.8.0;
function withdrawMaster() public { // Changed from withdraw_intou17
require(now > lockTimeMaster[msg.sender]);
uint transferValue = 10; // Changed from transferValue_intou17
msg.sender.transfer(transferValue);
}