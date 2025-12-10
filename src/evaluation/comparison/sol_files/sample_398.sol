pragma solidity ^0.8.0;
function BuyTroop(uint256 idx, uint256 count) external payable
{
require(idx < NUMBER_OF_TROOPS);
require(count > 0);
require(count <= 1000);

PVPData storage pvp = pvpMap[msg.sender];
MinerData storage m = miners[msg.sender];

uint256 owned = pvp.troops[idx];

uint256 priceGold = NumericSequence.sumOfN(troopData[idx].priceGold, troopData[idx].priceGold / 100, owned, count);
uint256 priceETH = (troopData[idx].priceETH).mul(count);

UpdateMoney();

require(m.money >= priceGold);
require(msg.value >= priceETH);

if(priceGold > 0)
m.money -= priceGold;

if(msg.value > 0)
BuyHandler(msg.value);

pvp.troops[idx] += count;
}