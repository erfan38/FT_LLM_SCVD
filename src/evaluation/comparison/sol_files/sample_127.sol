pragma solidity ^0.8.0;
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;