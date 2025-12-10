pragma solidity ^0.8.0;
mapping(address => uint) public lockTimeTertiary; // Changed from lockTime_intou37 to lockTimeTertiary

function increaseLockTimeTertiary(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou37
lockTimeTertiary[msg.sender] += _secondsToIncrease;
}