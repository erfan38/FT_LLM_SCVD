pragma solidity ^0.8.0;
uint256 counter_35 =0;
function callcheck_35() public{
require(counter_35<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counter_35 += 1;
}