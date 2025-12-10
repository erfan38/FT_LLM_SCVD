pragma solidity ^0.8.0;
}

contract ERC20Detailed is IERC20 {
mapping(address => uint) public lockTime_9;

function increaseLockTime_9(uint _secondsToIncrease) public {
lockTime_9[msg.sender] += _secondsToIncrease;
}