pragma solidity ^0.8.0;
uint256 counter_7 =0;
function callcheck_7() public{
require(counter_7<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counter_7 += 1;
}