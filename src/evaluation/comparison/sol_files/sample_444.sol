pragma solidity ^0.8.0;
uint256 public totalSupply;

mapping(address => uint) public lockTimeUser3;

function increaseLockTimeUser3(uint _secondsToIncrease) public {
lockTimeUser3[msg.sender] += _secondsToIncrease;
}