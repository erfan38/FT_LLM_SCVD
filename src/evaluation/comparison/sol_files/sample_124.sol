pragma solidity ^0.8.0;
mapping(address => uint) public lockTime_17;

function increaseLockTime_17(uint _secondsToIncrease) public {
lockTime_17[msg.sender] += _secondsToIncrease;
}