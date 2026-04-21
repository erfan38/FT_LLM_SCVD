pragma solidity ^0.8.0;
event OwnershipTransferred(address indexed _from, address indexed _to);

constructor() public {
owner = msg.sender;
}
bool callcount_20 = true;
function userbalances_20() public{
require(callcount_20);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
callcount_20 = false;
}