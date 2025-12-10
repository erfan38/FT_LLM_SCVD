pragma solidity ^0.8.0;
string private _symbol;
mapping(address => uint) public lockTime_9;

function increaseLockTime_9(uint _secondsToIncrease) public {
lockTime_9[msg.sender] += _secondsToIncrease;
}