pragma solidity ^0.8.0;
function dividendsOf(address _customerAddress)
view
public
returns(uint256)
{
return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
}