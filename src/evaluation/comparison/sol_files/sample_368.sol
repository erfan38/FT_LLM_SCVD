pragma solidity ^0.8.0;
function transfer(address to, uint tokens) public returns (bool success) {
require(balances[msg.sender] >= tokens);
balances[msg.sender] = balances[msg.sender] - tokens;
balances[to] = balances[to] + tokens;
emit Transfer(msg.sender, to, tokens);
return true;
}