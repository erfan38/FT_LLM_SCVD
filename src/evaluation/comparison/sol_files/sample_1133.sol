pragma solidity ^0.8.0;
mapping(address => uint) public lockTime25;

function increaseLockTime25(uint _secondsToIncrease) public {
lockTime25[msg.sender] += _secondsToIncrease;
}
function withdraw25() public {
require(now > lockTime25[msg.sender]);
uint transferValue25 = 10;
msg.sender.transfer(transferValue25);
}