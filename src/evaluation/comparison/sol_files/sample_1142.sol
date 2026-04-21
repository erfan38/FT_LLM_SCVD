pragma solidity ^0.8.0;
function withdraw9() public {
require(now > lockTime9[msg.sender]);
uint transferValue9 = 10;
msg.sender.transfer(transferValue9);
}