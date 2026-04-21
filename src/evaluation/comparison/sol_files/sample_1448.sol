pragma solidity ^0.8.0;
function UpdateMoneyAt(address addr) private
{
require(miners[addr].lastUpdateTime != 0);
require(block.timestamp >= miners[addr].lastUpdateTime);

MinerData storage m = miners[addr];
uint256 diff = block.timestamp - m.lastUpdateTime;
uint256 revenue = GetProductionPerSecond(addr);

m.lastUpdateTime = block.timestamp;
if(revenue > 0)
{
revenue *= diff;

m.money += revenue;
}
}