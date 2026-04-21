pragma solidity ^0.8.0;
function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
return true;
}