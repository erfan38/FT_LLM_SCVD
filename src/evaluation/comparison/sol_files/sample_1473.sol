pragma solidity ^0.8.0;
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = safeSub(balances[from], tokens);
allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
balances[to] = safeAdd(balances[to], tokens);
emit Transfer(from, to, tokens);
return true;
}