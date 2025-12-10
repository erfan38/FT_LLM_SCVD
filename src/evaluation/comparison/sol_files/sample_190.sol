pragma solidity ^0.8.0;
modifier onlyOwner {
require(msg.sender == owner);
_;
}

function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}