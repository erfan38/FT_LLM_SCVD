pragma solidity ^0.8.0;
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0, "SafeMath: division by zero");
uint256 c = a / b;

return c;
}