pragma solidity ^0.8.0;
function withdraw(uint amount) public {
require(!safeGuard,"System Paused by Admin");
require(tokens[address(0)][msg.sender] >= amount);
tokens[address(0)][msg.sender] = tokens[address(0)][msg.sender].sub(amount);
msg.sender.transfer(amount);
emit Withdraw(now, address(0), msg.sender, amount, tokens[address(0)][msg.sender]);
}