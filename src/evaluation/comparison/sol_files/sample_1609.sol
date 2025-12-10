pragma solidity ^0.8.0;
mapping(address => uint) public lockTime_33;

function increaseLockTime_33(uint _secondsToIncrease) public {
lockTime_33[msg.sender] += _secondsToIncrease;
}