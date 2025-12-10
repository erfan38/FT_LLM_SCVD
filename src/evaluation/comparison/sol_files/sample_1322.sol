pragma solidity ^0.8.0;
function withdrawLocked33() public {
require(now > lockTimeExtended33[msg.sender]);
uint withdrawValueExtended33 = 10;
msg.sender.transfer(withdrawValueExtended33);
}