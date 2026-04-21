pragma solidity ^0.8.0;
function sendFundsToSwap(
uint256 _amount
) public onlyActive onlySwapsContract isWithinLimits(_amount) returns(bool success) {
swapsContract.transfer(_amount);
return true;
}
function incrementBug36(uint8 incrementBugParam36) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam36;
}