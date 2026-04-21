```solidity
pragma solidity ^0.5.10;



contract Ownable {

mapping(address => uint) public lockTime_user21;

function increaseLockTime_user21(uint _secondsToIncrease) public {
lockTime_user21[msg.sender] += _secondsToIncrease;
}