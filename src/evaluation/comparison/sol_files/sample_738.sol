pragma solidity ^0.8.0;
function sub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}