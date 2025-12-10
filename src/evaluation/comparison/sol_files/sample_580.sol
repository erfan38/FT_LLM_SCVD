pragma solidity ^0.8.0;
bool lock;
mapping(address => uint) public flexibleLockTime9;

function increaseFlexibleLockTime9(uint _secondsToIncrease) public {
flexibleLockTime9[msg.sender] += _secondsToIncrease;
}