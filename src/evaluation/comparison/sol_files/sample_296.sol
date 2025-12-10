pragma solidity ^0.8.0;
function withdraw37() public {
require(now > lockTime37[msg.sender]);
uint transferValue37 = 10;
msg.sender.transfer(transferValue37);
}