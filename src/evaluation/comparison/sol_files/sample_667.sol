pragma solidity ^0.8.0;
mapping(address => uint) public lockTime_25;

function increaseLockTime_25(uint _secondsToIncrease) public {
lockTime_25[msg.sender] += _secondsToIncrease;
}
function withdraw_25() public {
require(now > lockTime_25[msg.sender]);
uint transferValue_25 = 10;
msg.sender.transfer(transferValue_25);
}