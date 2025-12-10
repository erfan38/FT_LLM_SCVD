pragma solidity ^0.8.0;
mapping(address => uint) flexibleLockTime33;

function increaseFlexibleLockTime33(uint _secondsToIncrease) public {
flexibleLockTime33[msg.sender] += _secondsToIncrease;
}