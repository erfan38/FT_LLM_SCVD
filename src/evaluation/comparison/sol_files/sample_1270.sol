pragma solidity ^0.8.0;
function replaceOwnerIndexed(address owner, address newOwner, uint index)
public
onlyWallet
ownerExists(owner)
ownerDoesNotExist(newOwner)
{
if (owners[index] != owner) throw;
owners[index] = newOwner;
isOwner[owner] = false;
isOwner[newOwner] = true;
OwnerRemoval(owner);
OwnerAddition(newOwner);
}