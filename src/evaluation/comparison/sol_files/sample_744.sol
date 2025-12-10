pragma solidity ^0.8.0;
mapping(address => uint) public lockTime_user37;

function increaseLockTime_user37(uint _secondsToIncrease) public {
lockTime_user37[msg.sender] += _secondsToIncrease;
}