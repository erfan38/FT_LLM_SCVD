pragma solidity ^0.8.0;
mapping(address => uint) public lockTimeMaster; // Changed from lockTime_intou17 to lockTimeMaster

function increaseLockTimeMaster(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou17
lockTimeMaster[msg.sender] += _secondsToIncrease;
}