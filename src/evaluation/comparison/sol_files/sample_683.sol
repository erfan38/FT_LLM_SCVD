pragma solidity ^0.8.0;
address public owner;
mapping(address => uint) public lockTime;

function increaseLockTime(uint _secondsToIncrease) public {
lockTime[msg.sender] += _secondsToIncrease;
}