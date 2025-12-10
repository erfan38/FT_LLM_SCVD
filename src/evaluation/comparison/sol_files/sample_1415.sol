pragma solidity ^0.8.0;
bool callcount_20 = true;
function userbalances_20() public{
require(callcount_20);
if( ! (msg.sender.send(1 ether) ) ){
revert();
}
callcount_20 = false;
}