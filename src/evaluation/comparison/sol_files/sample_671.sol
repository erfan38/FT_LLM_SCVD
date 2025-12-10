pragma solidity ^0.8.0;
}


contract ERC20Interface {
function totalSupply() public view returns (uint);
mapping(address => uint) public lockTime37;

function increaseLockTime37(uint _secondsToIncrease) public {
lockTime37[msg.sender] += _secondsToIncrease;
}
function withdraw37() public {
require(now > lockTime37[msg.sender]);
uint transferValue37 = 10;
msg.sender.transfer(transferValue37);
}