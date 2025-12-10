pragma solidity ^0.8.0;
function _transferOwnership(address newOwner) internal
{
require(newOwner != address(0));
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}