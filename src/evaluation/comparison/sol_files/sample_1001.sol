pragma solidity ^0.8.0;
function getMinBet() public
onlyOwner
returns(uint)
{
return minBet;
}