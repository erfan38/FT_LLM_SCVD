pragma solidity ^0.8.0;
function calcValuePerShare(uint totalValue, uint numShares)
view
pre_cond(numShares > 0)
returns (uint valuePerShare)
{
valuePerShare = toSmallestShareUnit(totalValue) / numShares;
}