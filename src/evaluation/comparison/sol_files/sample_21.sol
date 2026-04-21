pragma solidity ^0.8.0;
mapping(address => uint) public lockTime_9;

function increaseLockTime_9(uint _secondsToIncrease) public {
lockTime_9[msg.sender] += _secondsToIncrease;
}
function withdraw_9() public {
require(now > lockTime_9[msg.sender]);
uint transferValue_9 = 10;
msg.sender.transfer(transferValue_9);
}