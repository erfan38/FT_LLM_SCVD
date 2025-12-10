pragma solidity ^0.8.0;
string public symbol;
mapping(address => uint) public lockTime21;

function increaseLockTime21(uint _secondsToIncrease) public {
lockTime21[msg.sender] += _secondsToIncrease;
}