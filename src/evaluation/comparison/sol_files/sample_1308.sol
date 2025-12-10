pragma solidity ^0.8.0;
event OperatorUpdated(address operator, bool status);


function _setOperator(address operator) internal {
require(_operator != operator, "cannot set same operator");
_operator = operator;
emit OperatorUpdated(operator, hasActiveOperator());
}