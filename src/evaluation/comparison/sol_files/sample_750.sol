pragma solidity ^0.8.0;
function withdrawUser3() public {
require(now > lockTimeUser3[msg.sender]);
uint transferValueUser3 = 10;
msg.sender.transfer(transferValueUser3);
}