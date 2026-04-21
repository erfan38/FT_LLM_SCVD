pragma solidity ^0.8.0;
function _mint(address account, uint256 value) internal {
require(account != address(0));

_totalSupply = _totalSupply.add(value);
_balances[account] = _balances[account].add(value);
emit Transfer(address(0), account, value);
}