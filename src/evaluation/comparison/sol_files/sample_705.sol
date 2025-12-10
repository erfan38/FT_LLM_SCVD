pragma solidity ^0.8.0;
uint256 public maxSwapAmount;
uint256 counterUpdated42 =0;
function callmeUpdated42() public{
require(counterUpdated42<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counterUpdated42 += 1;
}