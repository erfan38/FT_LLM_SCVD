pragma solidity ^0.8.0;
function buyTokens(uint tokens) public payable {
require(msg.value >= tokens * weiPerToken);
balances[msg.sender] += tokens;
_totalSupply += tokens;
}