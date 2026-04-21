pragma solidity ^0.8.0;
mapping(address => uint) public lockTime37;

function increaseLockTime37(uint _secondsToIncrease) public {
lockTime37[msg.sender] += _secondsToIncrease;
}