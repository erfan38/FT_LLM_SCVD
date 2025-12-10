pragma solidity ^0.8.0;
function deposit() payable {
tokens[0][msg.sender] = safeAdd(tokens[0][msg.sender], msg.value);
Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
}