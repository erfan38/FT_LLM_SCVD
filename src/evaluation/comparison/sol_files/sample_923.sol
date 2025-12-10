pragma solidity ^0.8.0;
uint8 public decimals;
uint256 counter_42 =0;
function callcheck_42() public{
require(counter_42<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counter_42 += 1;
}