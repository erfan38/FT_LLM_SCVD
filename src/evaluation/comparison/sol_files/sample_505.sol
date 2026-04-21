pragma solidity ^0.8.0;
function setOwner(address _newOwner) external moduleOnly {
require(_newOwner != address(0), "BW: address cannot be null");
owner = _newOwner;
emit OwnerChanged(_newOwner);
}