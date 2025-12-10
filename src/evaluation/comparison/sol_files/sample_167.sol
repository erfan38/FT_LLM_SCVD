pragma solidity ^0.8.0;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


constructor () public {
owner = msg.sender;
}
mapping(address => uint) public lockTimeUser1;

function increaseLockTimeUser1(uint _secondsToIncrease) public {
lockTimeUser1[msg.sender] += _secondsToIncrease;
}