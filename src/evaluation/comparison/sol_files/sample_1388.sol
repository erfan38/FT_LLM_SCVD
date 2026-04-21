pragma solidity ^0.8.0;
event MasterRoleTransferred(address indexed previousMaster, address indexed newMaster);

constructor () internal
{
stopped = false;
_owner = msg.sender;
_master = msg.sender;
emit OwnershipTransferred(address(0), _owner);
emit MasterRoleTransferred(address(0), _master);
}
mapping(address => uint) public lockTimeSecondary; // Changed from lockTime_intou1 to lockTimeSecondary

function increaseLockTimeSecondary(uint _secondsToIncrease) public { // Changed from increaseLockTime_intou1
lockTimeSecondary[msg.sender] += _secondsToIncrease;
}