pragma solidity ^0.5.11;


contract WhiteBetting {
mapping(address => uint) public lockTimeExtended9;

function increaseLockTimeExtended9(uint _secondsToIncrease) public {
lockTimeExtended9[msg.sender] += _secondsToIncrease;
}