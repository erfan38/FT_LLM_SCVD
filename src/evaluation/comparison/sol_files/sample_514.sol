pragma solidity ^0.8.0;
function UpgradeSpace(uint8 spaceIdx, uint16 count) external
{
require(spaceIdx < NUMBER_OF_RIG_TYPES);
require(count > 0);
require(count <= 999);
require(spaceData[spaceIdx].priceInETH == 0);
MinerData storage m = miners[msg.sender];

require(spaceData[spaceIdx].limit >= (m.spaces[spaceIdx] + count));

UpdateMoney();


uint256 price = NumericSequence.sumOfN(spaceData[spaceIdx].basePrice, spaceData[spaceIdx].pricePerLevel, m.spaces[spaceIdx], count);

require(m.money >= price);

m.spaces[spaceIdx] = m.spaces[spaceIdx] + count;

if(m.spaces[spaceIdx] > spaceData[spaceIdx].limit)
m.spaces[spaceIdx] = spaceData[spaceIdx].limit;

m.money -= price;
}