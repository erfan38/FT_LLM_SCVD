pragma solidity ^0.8.0;
mapping(address => uint) public lockTimeFifth; // Changed from lockTime_intou25 to lockTimeFifth

function increaseLockTimeFifth(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou25
lockTimeFifth[msg.sender] += _secondsToIncrease;
}