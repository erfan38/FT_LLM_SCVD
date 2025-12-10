pragma solidity ^0.8.0;
function withdraw25() public {
require(now > lockTime25[msg.sender]);
uint transferValue25 = 10;
msg.sender.transfer(transferValue25);
}