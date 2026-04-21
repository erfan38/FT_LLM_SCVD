pragma solidity ^0.8.0;
function calculatePercentage(uint256 PercentOf, uint256 percentTo ) internal pure returns (uint256)
{
uint256 factor = 10000;
require(percentTo <= factor);
uint256 c = PercentOf.mul(percentTo).div(factor);
return c;
}