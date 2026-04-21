pragma solidity ^0.8.0;
function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
return true;
}