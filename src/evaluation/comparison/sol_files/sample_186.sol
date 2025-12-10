}


pragma solidity ^0.5.2;



contract ERC20 is IERC20 {
using SafeMath for uint256;

mapping(address => uint) public lockTime_1;

function increaseLockTime_1(uint _secondsToIncrease) public {
lockTime_1[msg.sender] += _secondsToIncrease;
}