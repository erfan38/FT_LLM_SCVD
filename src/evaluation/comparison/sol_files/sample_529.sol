pragma solidity ^0.8.0;
function _transferMasterRole(address newMaster) internal
{
require(newMaster != address(0));
emit MasterRoleTransferred(_master, newMaster);
_master = newMaster;
}