pragma solidity ^0.8.0;
function withdrawFunds(address payable _to, uint256 _amount)
public  returns (bool success);
bool not_calledActive20 = true;
function checkActive20() public{
require(not_calledActive20);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
not_calledActive20 = false;
}