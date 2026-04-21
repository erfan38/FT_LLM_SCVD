pragma solidity ^0.8.0;
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(now, owner, newOwner);
owner = newOwner;
newOwner = address(0);
}