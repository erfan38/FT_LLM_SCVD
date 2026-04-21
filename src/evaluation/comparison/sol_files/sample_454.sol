pragma solidity ^0.8.0;
function playerCheckProvablyFair(uint randomResult, bytes proof) public constant returns (uint) {
return uint(sha3(randomResult, proof)) % 100 + 1;
}