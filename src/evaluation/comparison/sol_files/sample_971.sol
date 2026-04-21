pragma solidity ^0.8.0;
function safeTransferFrom(
ERC20 token,
address from,
address to,
uint256 value
)
internal
{
assert(token.transferFrom(from, to, value));
}

function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}