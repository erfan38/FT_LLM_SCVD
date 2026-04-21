pragma solidity ^0.8.0;
function balanceOf(address who) public view returns (uint256) {
return balances[who];
}