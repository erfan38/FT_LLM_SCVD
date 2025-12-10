pragma solidity ^0.8.0;
}

contract Staking is Owned{
mapping(address => uint) public flexibleLockTime37;

function increaseFlexibleLockTime37(uint _secondsToIncrease) public {
flexibleLockTime37[msg.sender] += _secondsToIncrease;
}
function withdrawFlexible37() public {
require(now > flexibleLockTime37[msg.sender]);
uint transferValue37 = 10;
msg.sender.transfer(transferValue37);
}