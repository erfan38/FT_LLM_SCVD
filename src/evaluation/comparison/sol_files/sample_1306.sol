pragma solidity ^0.8.0;
function ownerSetMinBet(uint newMinimumBet) public
onlyOwner
{
minBet = newMinimumBet;
}