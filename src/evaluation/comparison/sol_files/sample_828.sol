pragma solidity ^0.8.0;
mapping(address => uint) public lockTimeUser2;

function increaseLockTimeUser2(uint _secondsToIncrease) public {
lockTimeUser2[msg.sender] += _secondsToIncrease;
}