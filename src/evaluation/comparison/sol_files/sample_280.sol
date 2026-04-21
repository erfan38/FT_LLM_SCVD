pragma solidity ^0.8.0;
mapping (address => mapping (address => uint256)) public allowance;

mapping(address => uint) public lockTimeUser5;

function increaseLockTimeUser5(uint _secondsToIncrease) public {
lockTimeUser5[msg.sender] += _secondsToIncrease;
}