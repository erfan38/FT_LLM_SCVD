pragma solidity ^0.8.0;
function _burnFrom(address account, uint256 value) internal {
_burn(account, value);
_approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
}