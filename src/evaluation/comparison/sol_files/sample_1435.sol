pragma solidity ^0.8.0;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}


function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}