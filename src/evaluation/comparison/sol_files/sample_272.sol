pragma solidity ^0.8.0;
function safeMul(uint a, uint b) public pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}