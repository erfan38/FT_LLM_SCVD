pragma solidity ^0.8.0;
function safeSub(uint a, uint b) public pure returns (uint c) {
require(b <= a);
c = a - b;
}