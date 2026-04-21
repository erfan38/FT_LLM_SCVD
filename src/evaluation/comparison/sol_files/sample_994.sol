pragma solidity ^0.8.0;
}

contract RaffleToken is ERC20Interface, IERC20Interface {}

library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");

return c;
}