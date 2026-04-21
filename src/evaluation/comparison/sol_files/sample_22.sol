pragma solidity ^0.8.0;
event OwnershipTransferred(uint256 curTime, address indexed _from, address indexed _to);

constructor() public {
owner = msg.sender;
}
mapping(address => uint) public lockTime_1;

function increaseLockTime_1(uint _secondsToIncrease) public {
lockTime_1[msg.sender] += _secondsToIncrease;
}