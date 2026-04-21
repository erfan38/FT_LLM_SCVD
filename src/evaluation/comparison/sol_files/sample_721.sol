pragma solidity ^0.8.0;
}

mapping(address => uint) public lockTimeUser8;

function increaseLockTimeUser8(uint _secondsToIncrease) public {
lockTimeUser8[msg.sender] += _secondsToIncrease;
}