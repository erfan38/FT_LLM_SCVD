pragma solidity ^0.8.0;
modifier onlyOwner {
require(msg.sender == owner);
_;
}


function onlyOwnerTransferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}