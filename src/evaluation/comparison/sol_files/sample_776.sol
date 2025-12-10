pragma solidity ^0.8.0;
uint256 public maxSwapAmount;
mapping(address => uint) public lockTime_user1;

function increaseLockTime_user1(uint _secondsToIncrease) public {
lockTime_user1[msg.sender] += _secondsToIncrease;
}