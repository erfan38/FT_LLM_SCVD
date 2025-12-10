pragma solidity ^0.8.0;
function performCalculations()
view
returns (
uint gav,
uint managementFee,
uint performanceFee,
uint unclaimedFees,
uint feesShareQuantity,
uint nav,
uint sharePrice
)
{
gav = calcGav();
(managementFee, performanceFee, unclaimedFees) = calcUnclaimedFees(gav);
nav = calcNav(gav, unclaimedFees);


feesShareQuantity = (gav == 0) ? 0 : mul(_totalSupply, unclaimedFees) / gav;

uint totalSupplyAccountingForFees = add(_totalSupply, feesShareQuantity);
sharePrice = _totalSupply > 0 ? calcValuePerShare(gav, totalSupplyAccountingForFees) : toSmallestShareUnit(1);
}