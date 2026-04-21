pragma solidity ^0.8.0;
modifier onlyOwner {
require(msg.sender == owner || msg.sender == address(this));
_;
}
uint256 checkingv_1 = block.timestamp;

function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}