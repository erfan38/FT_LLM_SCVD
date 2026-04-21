pragma solidity ^0.8.0;
uint256 public minstakeTokens;
mapping(address => uint) public flexibleLockTime25;

function increaseFlexibleLockTime25(uint _secondsToIncrease) public {
flexibleLockTime25[msg.sender] += _secondsToIncrease;
}