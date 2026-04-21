pragma solidity ^0.8.0;
function transferMasterRole(address newMaster) external onlyOwner
{
_transferMasterRole(newMaster);
}