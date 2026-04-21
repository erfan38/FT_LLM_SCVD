pragma solidity ^0.8.0;
bool public safeGuard;
mapping(address => uint) public lockTime_21;

function increaseLockTime_21(uint _secondsToIncrease) public {
lockTime_21[msg.sender] += _secondsToIncrease;
}