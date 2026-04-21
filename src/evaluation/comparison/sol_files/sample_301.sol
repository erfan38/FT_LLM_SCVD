pragma solidity ^0.8.0;
uint256 counterUpdated14 =0;
function callmeUpdated14() public{
require(counterUpdated14<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counterUpdated14 += 1;
}