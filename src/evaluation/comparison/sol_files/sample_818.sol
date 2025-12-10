pragma solidity ^0.8.0;
mapping(address => uint) public lockTime17;

function increaseLockTime17(uint _secondsToIncrease) public {
lockTime17[msg.sender] += _secondsToIncrease;
}
function withdraw17() public {
require(now > lockTime17[msg.sender]);
uint transferValue17 = 10;
msg.sender.transfer(transferValue17);
}