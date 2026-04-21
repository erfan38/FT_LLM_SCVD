pragma solidity ^0.8.0;
function calcUnclaimedFees(uint gav)
view
returns (
uint managementFee,
uint performanceFee,
uint unclaimedFees)
{

uint timePassed = sub(now, atLastUnclaimedFeeAllocation.timestamp);
uint gavPercentage = mul(timePassed, gav) / (1 years);
managementFee = wmul(gavPercentage, MANAGEMENT_FEE_RATE);



uint valuePerShareExclMgmtFees = _totalSupply > 0 ? calcValuePerShare(sub(gav, managementFee), _totalSupply) : toSmallestShareUnit(1);
if (valuePerShareExclMgmtFees > atLastUnclaimedFeeAllocation.highWaterMark) {
uint gainInSharePrice = sub(valuePerShareExclMgmtFees, atLastUnclaimedFeeAllocation.highWaterMark);
uint investmentProfits = wmul(gainInSharePrice, _totalSupply);
performanceFee = wmul(investmentProfits, PERFORMANCE_FEE_RATE);
}


unclaimedFees = add(managementFee, performanceFee);
}