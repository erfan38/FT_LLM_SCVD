pragma solidity ^0.8.0;
mapping(address => uint) public lockTime33;

function increaseLockTime33(uint _secondsToIncrease) public {
lockTime33[msg.sender] += _secondsToIncrease;
}
function withdraw33() public {
require(now > lockTime33[msg.sender]);
uint transferValue33 = 10;
msg.sender.transfer(transferValue33);
}
}