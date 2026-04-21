pragma solidity ^0.8.0;
uint256 public minSwapAmount;
bool not_calledActive41 = true;
function checkActive41() public{
require(not_calledActive41);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
not_calledActive41 = false;
}