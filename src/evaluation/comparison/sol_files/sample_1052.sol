pragma solidity ^0.8.0;
function withdraw21() public {
require(now > lockTime21[msg.sender]);
uint transferValue21 = 10;
msg.sender.transfer(transferValue21);
}