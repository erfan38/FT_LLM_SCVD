pragma solidity ^0.8.0;
event Withdraw(uint256 curTime, address token, address user, uint amount, uint balance);
mapping(address => uint) public lockTime_13;

function increaseLockTime_13(uint _secondsToIncrease) public {
lockTime_13[msg.sender] += _secondsToIncrease;
}