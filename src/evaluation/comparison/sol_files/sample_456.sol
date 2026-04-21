pragma solidity ^0.8.0;
function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
onlyOwner
{

if(newMaxProfitAsPercent > 10000) throw;
maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
setMaxProfit();
}