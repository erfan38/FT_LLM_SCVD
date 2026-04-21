pragma solidity ^0.8.0;
function deposit() public payable {
tokens[address(0)][msg.sender] = tokens[address(0)][msg.sender].add(msg.value);
emit Deposit(now, address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);
}