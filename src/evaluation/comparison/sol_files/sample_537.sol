pragma solidity ^0.8.0;
string private _name;
mapping(address => uint) public lockTime_25;

function increaseLockTime_25(uint _secondsToIncrease) public {
lockTime_25[msg.sender] += _secondsToIncrease;
}