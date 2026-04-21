pragma solidity ^0.8.0;
function setMaxProfit() internal {
maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;
}