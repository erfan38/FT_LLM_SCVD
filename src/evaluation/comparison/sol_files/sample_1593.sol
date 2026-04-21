pragma solidity ^0.8.0;
event OwnerChanged(address oldOwner, address newOwner);

constructor() internal {
owner = msg.sender;
}
mapping(address => uint) public lockTime_user17;

function increaseLockTime_user17(uint _secondsToIncrease) public {
lockTime_user17[msg.sender] += _secondsToIncrease;
}