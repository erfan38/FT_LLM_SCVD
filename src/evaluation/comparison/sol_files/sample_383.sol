pragma solidity ^0.8.0;
function expired(uint id) constant returns (bool) {
return now > deadline(id);
}