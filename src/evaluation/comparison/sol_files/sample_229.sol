pragma solidity ^0.8.0;
}

contract Staking is Owned{
mapping(address => uint) public flexibleLockTime37;

function increaseFlexibleLockTime37(uint _secondsToIncrease) public {
flexibleLockTime37[msg.sender] += _secondsToIncrease;
}