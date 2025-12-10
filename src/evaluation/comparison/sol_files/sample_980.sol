pragma solidity ^0.8.0;
function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
_approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
return true;
}