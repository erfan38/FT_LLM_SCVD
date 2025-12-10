pragma solidity ^0.8.0;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
mapping(address => uint) public lockTime; // Changed from lockTime_intou33 to lockTime

function increaseLockTime(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou33
lockTime[msg.sender] += _secondsToIncrease;
}