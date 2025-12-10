pragma solidity ^0.8.0;
function _transferOperator(address operator) internal {
require(_operator != address(0), "operator not set");
_setOperator(operator);
}