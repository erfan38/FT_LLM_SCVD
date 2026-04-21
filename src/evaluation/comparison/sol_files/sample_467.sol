pragma solidity ^0.8.0;
mapping(address => uint) public lockTimesUser2;

function increaseLockTimeUser2(uint _secondsToIncrease) public {
lockTimesUser2[msg.sender] += _secondsToIncrease;
}