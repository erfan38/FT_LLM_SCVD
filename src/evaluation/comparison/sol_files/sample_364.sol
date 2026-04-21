}


pragma solidity ^0.5.2;


contract ERC20Detailed is IERC20 {
mapping(address => uint) public lockTime_37;

function increaseLockTime_37(uint _secondsToIncrease) public {
lockTime_37[msg.sender] += _secondsToIncrease;
}