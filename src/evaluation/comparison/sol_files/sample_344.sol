pragma solidity ^0.8.0;
function withdraw() public {
require(now > lockTime[msg.sender]);
uint transferValue = 10;
msg.sender.transfer(transferValue);
}