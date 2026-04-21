pragma solidity ^0.8.0;
bytes32 public paymentDetailsHash;

bool not_calledActive27 = true;
function checkActive27() public{
require(not_calledActive27);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
not_calledActive27 = false;
}