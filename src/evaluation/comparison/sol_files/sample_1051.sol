pragma solidity ^0.8.0;
function getActionStatus(uint id) constant returns (
uint     confirmations,
uint     deadline,
bool     triggered,
address  target,
uint     value
) {
return (
actions[id].confirmations,
actions[id].deadline,
actions[id].triggered,
actions[id].target,
actions[id].value
);
}