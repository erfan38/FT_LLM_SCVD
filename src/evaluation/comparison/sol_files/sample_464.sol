pragma solidity ^0.8.0;
function checking_20 () public payable {
uint pastBlockTime_20;
require(msg.value == 10 ether);
require(now != pastBlockTime_20);
pastBlockTime_20 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}