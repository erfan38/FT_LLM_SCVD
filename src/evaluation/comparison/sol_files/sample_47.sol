pragma solidity ^0.8.0;
function _burn(address account, uint256 value) internal {
require(account != address(0), "ERC20: burn from the zero address");

_totalSupply = _totalSupply.sub(value);
_balances[account] = _balances[account].sub(value);
emit Transfer(account, address(0), value);
}