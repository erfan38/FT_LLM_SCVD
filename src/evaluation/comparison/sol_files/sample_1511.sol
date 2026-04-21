pragma solidity ^0.8.0;
function setMetadata(bytes memory metadata) public {
require(Template.isCreator(msg.sender) || Operated.isActiveOperator(msg.sender), "only active operator or creator");

EventMetadata._setMetadata(metadata);
}