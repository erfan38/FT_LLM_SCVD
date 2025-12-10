pragma solidity ^0.8.0;
function withdrawUser1() public {
require(now > lockTimesUser1[msg.sender]);
uint transferValueUser1 = 10;
msg.sender.transfer(transferValueUser1);
}