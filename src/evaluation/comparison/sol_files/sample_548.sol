pragma solidity ^0.8.0;
function value(uint id) constant returns (uint) {
return actions[id].value;
}