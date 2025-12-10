pragma solidity ^0.8.0;
function lock(address beneficiary, uint256 amount)
external
{
require(msg.sender == locker);
require(beneficiary != address(0));
buyers[beneficiary] += amount;
emit TokenLocked(beneficiary, buyers[beneficiary]);
}