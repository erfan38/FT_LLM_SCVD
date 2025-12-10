pragma solidity ^0.8.0;
function _burnFrom(address account, uint256 amount) internal {
_burn(account, amount);
_approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
}