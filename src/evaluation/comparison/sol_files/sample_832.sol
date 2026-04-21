pragma solidity ^0.8.0;
function withdrawToken(address token, uint amount) public {
require(!safeGuard,"System Paused by Admin");
require(token!=address(0));
require(tokens[token][msg.sender] >= amount);
tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);
ERC20Essential(token).transfer(msg.sender, amount);
emit Withdraw(now, token, msg.sender, amount, tokens[token][msg.sender]);
}