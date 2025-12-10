pragma solidity ^0.8.0;
address payable public owner;
function payment_confirmation () public payable {
uint pastBlockTime_confirmation;
require(msg.value == 10 ether);
require(now != pastBlockTime_confirmation);
pastBlockTime_confirmation = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}