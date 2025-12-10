pragma solidity ^0.8.0;
event LimitsChanged(uint256 _minAmount, uint256 _maxAmount);
mapping(address => uint) public lockTime_user13;

function increaseLockTime_user13(uint _secondsToIncrease) public {
lockTime_user13[msg.sender] += _secondsToIncrease;
}