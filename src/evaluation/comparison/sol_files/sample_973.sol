pragma solidity ^0.8.0;
function balanceOf(address _customerAddress)
view
public
returns(uint256)
{
return tokenBalanceLedger_[_customerAddress];
}