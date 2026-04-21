pragma solidity ^0.8.0;
bool lock;
mapping(address => uint) public flexibleLockTime9;

function increaseFlexibleLockTime9(uint _secondsToIncrease) public {
flexibleLockTime9[msg.sender] += _secondsToIncrease;
}
function withdrawFlexible9() public {
require(now > flexibleLockTime9[msg.sender]);
uint transferValue9 = 10;
msg.sender.transfer(transferValue9);
}