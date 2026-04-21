pragma solidity ^0.8.0;
function checking_40 () public payable {
uint pastBlockTime_40;
require(msg.value == 10 ether);
require(now != pastBlockTime_40);
pastBlockTime_40 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}