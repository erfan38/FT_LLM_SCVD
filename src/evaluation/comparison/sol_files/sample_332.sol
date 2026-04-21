pragma solidity ^0.8.0;
function _activateOperator() internal {
require(!hasActiveOperator(), "only when operator not active");
_status = true;
emit OperatorUpdated(_operator, true);
}