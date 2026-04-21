pragma solidity ^0.8.0;
function payYearlyJackpot(address yearlyContract) onlyOwner public {
require(jackpotBalance > 0);

if (yearlyContract.call.value(jackpotBalance).gas(50000)()) {
jackpotBalance = 0;
emit OnYJPCharged(jackpotBalance);
}
}