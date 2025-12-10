pragma solidity ^0.8.0;
function calcSharePriceAndAllocateFees() public returns (uint)
{
var (
gav,
managementFee,
performanceFee,
unclaimedFees,
feesShareQuantity,
nav,
sharePrice
) = performCalculations();

createShares(owner, feesShareQuantity);


uint highWaterMark = atLastUnclaimedFeeAllocation.highWaterMark >= sharePrice ? atLastUnclaimedFeeAllocation.highWaterMark : sharePrice;
atLastUnclaimedFeeAllocation = Calculations({
gav: gav,
managementFee: managementFee,
performanceFee: performanceFee,
unclaimedFees: unclaimedFees,
nav: nav,
highWaterMark: highWaterMark,
totalSupply: _totalSupply,
timestamp: now
});

emit FeesConverted(now, feesShareQuantity, unclaimedFees);
emit CalculationUpdate(now, managementFee, performanceFee, nav, sharePrice, _totalSupply);

return sharePrice;
}