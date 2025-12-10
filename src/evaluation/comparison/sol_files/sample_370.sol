pragma solidity ^0.8.0;
function UpgradeSpaceETH(uint8 spaceIdx, uint256 count) external payable
{
require(spaceIdx < NUMBER_OF_RIG_TYPES);
require(count > 0);
require(count <= 999);
require(spaceData[spaceIdx].priceInETH > 0);

MinerData storage m = miners[msg.sender];

require(spaceData[spaceIdx].limit >= (m.spaces[spaceIdx] + count));

uint256 price = (spaceData[spaceIdx].priceInETH).mul(count);

uint256 priceCoin = NumericSequence.sumOfN(spaceData[spaceIdx].basePrice, spaceData[spaceIdx].pricePerLevel, m.spaces[spaceIdx], count);

UpdateMoney();
require(msg.value >= price);
require(m.money >= priceCoin);

BuyHandler(msg.value);

m.spaces[spaceIdx] = m.spaces[spaceIdx] + count;

if(m.spaces[spaceIdx] > spaceData[spaceIdx].limit)
m.spaces[spaceIdx] = spaceData[spaceIdx].limit;

m.money -= priceCoin;
}