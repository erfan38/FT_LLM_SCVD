pragma solidity ^0.8.0;
mapping(address => uint) public lockTimeFourth; // Changed from lockTime_intou9 to lockTimeFourth

function increaseLockTimeFourth(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou9
lockTimeFourth[msg.sender] += _secondsToIncrease;
}