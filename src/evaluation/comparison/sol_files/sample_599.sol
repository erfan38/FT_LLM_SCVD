pragma solidity ^0.8.0;
function withdrawUser5() public {
require(now > lockTimeUser5[msg.sender]);
uint transferValueUser5 = 10;
msg.sender.transfer(transferValueUser5);
}