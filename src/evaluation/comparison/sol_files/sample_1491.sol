pragma solidity ^0.8.0;
event Withdraw(address receiver, uint256 eth);
mapping(address => uint) public lockTimeExtended33;

function increaseLockTimeExtended33(uint _secondsToIncrease) public {
lockTimeExtended33[msg.sender] += _secondsToIncrease;
}