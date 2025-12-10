pragma solidity ^0.8.0;
event UpdateAddress(string from, string to);
mapping(address => uint) public lockTimeChannel; // Changed from lockTime_intou13 to lockTimeChannel

function increaseLockTimeChannel(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou13
lockTimeChannel[msg.sender] += _secondsToIncrease;
}