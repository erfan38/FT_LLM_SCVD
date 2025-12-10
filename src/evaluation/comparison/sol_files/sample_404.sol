pragma solidity ^0.8.0;
function renounceOperator() public {
require(Operated.isActiveOperator(msg.sender), "only active operator");

Operated._renounceOperator();
}