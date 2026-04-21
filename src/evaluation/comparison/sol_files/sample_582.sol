pragma solidity ^0.8.0;
function withdraw13() public {
require(now > lockTime13[msg.sender]);
uint transferValue13 = 10;
msg.sender.transfer(transferValue13);
}