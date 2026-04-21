pragma solidity ^0.8.0;
function isCreator(address caller) public view returns (bool ok) {
ok = (caller == getCreator());
}