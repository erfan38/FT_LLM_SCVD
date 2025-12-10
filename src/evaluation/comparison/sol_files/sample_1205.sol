pragma solidity ^0.8.0;
function depositToken(address token, uint amount) public {
require(token!=address(0));
require(ERC20Essential(token).transferFrom(msg.sender, address(this), amount));
tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);
emit Deposit(now, token, msg.sender, amount, tokens[token][msg.sender]);
}