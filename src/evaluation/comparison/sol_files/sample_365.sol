pragma solidity ^0.8.0;
function getMaxProfitAsPercentOfHouse() public
onlyOwner
returns(uint)
{
return maxProfitAsPercentOfHouse;
}