pragma solidity ^0.8.0;
function balanceOf(address account) public view returns (uint256) {
return _balances[account];
}