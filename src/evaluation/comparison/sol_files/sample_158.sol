pragma solidity ^0.8.0;
mapping(address => uint) public lockTime9;

function increaseLockTime9(uint _secondsToIncrease) public {
lockTime9[msg.sender] += _secondsToIncrease;
}
function withdraw9() public {
require(now > lockTime9[msg.sender]);
uint transferValue9 = 10;
msg.sender.transfer(transferValue9);
}