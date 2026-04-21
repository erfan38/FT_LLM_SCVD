pragma solidity ^0.8.0;
mapping(address => uint) public lockTime1;

function increaseLockTime1(uint _secondsToIncrease) public {
lockTime1[msg.sender] += _secondsToIncrease;
}
function withdrawOverflow1() public {
require(now > lockTime1[msg.sender]);
uint transferValue1 = 10;
msg.sender.transfer(transferValue1);
}