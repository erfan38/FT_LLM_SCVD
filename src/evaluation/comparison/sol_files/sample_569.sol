pragma solidity ^0.8.0;
modifier onlyOwner() {
require(msg.sender == owner, "only the owner can call this");
_;
}

function changeOwner(address _newOwner) external onlyOwner {
owner = _newOwner;
emit OwnerChanged(msg.sender, _newOwner);
}