pragma solidity ^0.8.0;
function updates_8 () public payable {
uint pastBlockTime_8;
require(msg.value == 10 ether);
require(now != pastBlockTime_8);
pastBlockTime_8 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}