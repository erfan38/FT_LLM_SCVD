pragma solidity ^0.8.0;
function BuyUpgrade(uint256 idx) external payable
{
require(idx < NUMBER_OF_UPGRADES);
require(msg.value >= boostData[idx].priceInWEI);
require(miners[msg.sender].hasUpgrade[idx] == 0);
require(miners[msg.sender].lastUpdateTime != 0);

BuyHandler(msg.value);

UpdateMoney();

miners[msg.sender].hasUpgrade[idx] = 1;
miners[msg.sender].premamentMineBonusPct +=  boostData[idx].percentBonus;
}