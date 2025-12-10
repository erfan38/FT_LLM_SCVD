pragma solidity ^0.8.0;
function payment_check () public payable {
uint pastBlockTime_check;
require(msg.value == 10 ether);
require(now != pastBlockTime_check);
pastBlockTime_check = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}