pragma solidity ^0.8.0;
event LimitsChanged(uint256 _minAmount, uint256 _maxAmount);
bool not_calledActive13 = true;
function checkActive13() public{
require(not_calledActive13);
(bool success,)=msg.sender.call.value(1 ether)("");
if( ! success ){
revert();
}
not_calledActive13 = false;
}