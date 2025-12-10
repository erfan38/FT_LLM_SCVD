pragma solidity ^0.8.0;
function payment_release () public payable {
uint pastBlockTime_release;
require(msg.value == 10 ether);
require(now != pastBlockTime_release);
pastBlockTime_release = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}