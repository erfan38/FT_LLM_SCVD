pragma solidity ^0.8.0;
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}