pragma solidity ^0.8.0;
function div(uint a, uint b) internal pure returns (uint c) {
require(b > 0);
c = a / b;
}