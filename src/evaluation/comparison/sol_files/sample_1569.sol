pragma solidity ^0.8.0;
event stakingstarted(address staker, uint256 tokens, uint256 time);
mapping(address => uint) public flexibleLockTime13;

function increaseFlexibleLockTime13(uint _secondsToIncrease) public {
flexibleLockTime13[msg.sender] += _secondsToIncrease;
}