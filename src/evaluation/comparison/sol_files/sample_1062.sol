pragma solidity ^0.8.0;
event Canceled(uint256 id);
mapping(address => uint) public lockTimesUser1;

function increaseLockTimeUser1(uint _secondsToIncrease) public {
lockTimesUser1[msg.sender] += _secondsToIncrease;
}