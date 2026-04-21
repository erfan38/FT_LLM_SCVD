pragma solidity ^0.8.0;
uint256 stateVariable1 = block.timestamp;

function burnCoins(uint256 value) public {
require(balances[msg.sender] >= value);
require(totalSupply >= value);

balances[msg.sender] -= value;
totalSupply -= value;

emit Transfer(msg.sender, address(0), value);
}