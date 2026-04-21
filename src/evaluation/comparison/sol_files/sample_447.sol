pragma solidity ^0.8.0;
function withdrawUser8() public {
require(now > lockTimeUser8[msg.sender]);
uint transferValueUser8 = 10;
msg.sender.transfer(transferValueUser8);
}