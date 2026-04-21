pragma solidity ^0.8.0;
function _deactivateOperator() internal {
require(hasActiveOperator(), "only when operator active");
_status = false;
emit OperatorUpdated(_operator, false);
}