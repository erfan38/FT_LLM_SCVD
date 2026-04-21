pragma solidity ^0.8.0;
function _renounceOperator() internal {
require(hasActiveOperator(), "only when operator active");
_operator = address(0);
_status = false;
emit OperatorUpdated(address(0), false);
}