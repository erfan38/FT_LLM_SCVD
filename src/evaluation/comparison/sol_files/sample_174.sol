pragma solidity ^0.8.0;
function GetBoosterData() public constant returns (address[5] _boosterHolders, uint256 currentPrice, uint256 currentIndex)
{
for(uint i = 0; i < NUMBER_OF_BOOSTERS; ++i)
{
_boosterHolders[i] = boosterHolders[i];
}
currentPrice = nextBoosterPrice;
currentIndex = boosterIndex;
}