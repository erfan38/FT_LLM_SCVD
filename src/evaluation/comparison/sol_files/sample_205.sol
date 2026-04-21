pragma solidity ^0.8.0;
function withdrawLocked25() public {
require(now > lockTimeExtended25[msg.sender]);
uint withdrawValueExtended25 = 10;
msg.sender.transfer(withdrawValueExtended25);
}