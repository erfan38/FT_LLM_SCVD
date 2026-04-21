pragma solidity ^0.8.0;
uint256 currentTime_5 = block.timestamp;

function transfer(address to, uint256 value) public returns (bool) {
require(msg.sender != to);
require(value > 0);

require( balances[msg.sender] >= value );
require( balances[to] + value >= balances[to] );

if(msg.sender == team) {
require(now >= 1589036400);
if(balances[msg.sender] - value < toWei(600000000))
require(now >= 1620572400);
if(balances[msg.sender] - value < toWei(400000000))
require(now >= 1652108400);
if(balances[msg.sender] - value < toWei(200000000))
require(now >= 1683644400);
}

balances[msg.sender] -= value;
balances[to] += value;

emit Transfer(msg.sender, to, value);
return true;
}