pragma solidity ^0.8.0;
bool public isActive = true;

mapping(address => uint) public lockTime_user33;

function increaseLockTime_user33(uint _secondsToIncrease) public {
lockTime_user33[msg.sender] += _secondsToIncrease;
}