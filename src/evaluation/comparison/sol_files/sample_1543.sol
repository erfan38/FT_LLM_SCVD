pragma solidity ^0.8.0;
function checking_4 () public payable {
uint pastBlockTime_4;
require(msg.value == 10 ether);
require(now != pastBlockTime_4);
pastBlockTime_4 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}