pragma solidity ^0.8.0;
address public newOwner;

mapping(address => uint) public lockTime13;

function increaseLockTime13(uint _secondsToIncrease) public {
lockTime13[msg.sender] += _secondsToIncrease;
}