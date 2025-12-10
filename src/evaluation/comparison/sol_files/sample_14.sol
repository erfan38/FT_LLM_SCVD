pragma solidity ^0.8.0;
function ownerChangeOwner(address newOwner) public
onlyOwner
{
owner = newOwner;
}