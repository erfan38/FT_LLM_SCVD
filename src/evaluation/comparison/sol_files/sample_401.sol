pragma solidity ^0.8.0;
function isOperator(address caller) public view returns (bool ok) {
return (caller == getOperator());
}