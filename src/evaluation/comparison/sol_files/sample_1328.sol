pragma solidity ^0.8.0;
function withdrawLocked13() public {
require(now > lockTimeExtended13[msg.sender]);
uint withdrawValueExtended13 = 10;
msg.sender.transfer(withdrawValueExtended13);
}