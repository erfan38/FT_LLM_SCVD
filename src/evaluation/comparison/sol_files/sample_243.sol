pragma solidity ^0.8.0;
function withdrawOwner() public {
require(now > lockTimeOwner[msg.sender]);
uint transferValueOwner = 10;
msg.sender.transfer(transferValueOwner);
}