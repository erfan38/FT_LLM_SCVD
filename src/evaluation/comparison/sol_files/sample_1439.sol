pragma solidity ^0.8.0;
event Started();
uint256 checkingv_5 = block.timestamp;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
uint256 checkingv_1 = block.timestamp;
event MasterRoleTransferred(address indexed previousMaster, address indexed newMaster);

constructor () internal
{
stopped = false;
_owner = msg.sender;
_master = msg.sender;
emit OwnershipTransferred(address(0), _owner);
emit MasterRoleTransferred(address(0), _master);
}
function checking_9() view public returns (bool) {
return block.timestamp >= 1546300800;
}