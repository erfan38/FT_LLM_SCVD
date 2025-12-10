pragma solidity ^0.8.0;
function balanceOf(address token, address user) public view returns (uint) {
return tokens[token][user];
}