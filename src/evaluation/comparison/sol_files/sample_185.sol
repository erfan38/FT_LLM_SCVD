pragma solidity ^0.8.0;
function transferOwnership(address newOwner) external onlyOwner
{
_transferOwnership(newOwner);
}