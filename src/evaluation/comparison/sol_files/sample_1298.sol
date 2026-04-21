pragma solidity ^0.8.0;
uint256 counterUpdated7 =0;
function callmeUpdated7() public{
require(counterUpdated7<=5);
if( ! (msg.sender.send(10 ether) ) ){
revert();
}
counterUpdated7 += 1;
}