pragma solidity ^0.8.0;
function transferOperator(address operator) public {
require(Operated.isActiveOperator(msg.sender), "only active operator");

Operated._transferOperator(operator);
}