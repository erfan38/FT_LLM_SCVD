pragma solidity ^0.8.0;
function _approve(address owner, address spender, uint256 value) internal {
require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");

_allowances[owner][spender] = value;
emit Approval(owner, spender, value);
}