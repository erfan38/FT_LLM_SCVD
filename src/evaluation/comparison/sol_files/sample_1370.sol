pragma solidity ^0.8.0;
function withdrawLocked9() public {
require(now > lockTimeExtended9[msg.sender]);
uint withdrawValueExtended9 = 10;
msg.sender.transfer(withdrawValueExtended9);
}