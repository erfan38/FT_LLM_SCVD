pragma solidity ^0.8.0;
function UpdateMoney() private
{
require(miners[msg.sender].lastUpdateTime != 0);
require(block.timestamp >= miners[msg.sender].lastUpdateTime);

MinerData storage m = miners[msg.sender];
uint256 diff = block.timestamp - m.lastUpdateTime;
uint256 revenue = GetProductionPerSecond(msg.sender);

m.lastUpdateTime = block.timestamp;
if(revenue > 0)
{
revenue *= diff;

m.money += revenue;
}
}