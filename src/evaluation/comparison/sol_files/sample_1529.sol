pragma solidity ^0.5.0;



contract SafeMath {
function safeAdd(uint a, uint b) public pure returns (uint c) {
c = a + b;
require(c >= a);
}