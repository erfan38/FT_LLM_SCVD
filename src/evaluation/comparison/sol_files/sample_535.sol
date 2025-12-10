pragma solidity ^0.8.0;
function changeOwner(address payable _newOwner ) external onlyOwner {
owner = _newOwner;
}