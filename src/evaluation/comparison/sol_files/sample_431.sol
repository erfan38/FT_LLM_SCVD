pragma solidity ^0.8.0;
function checking_36 () public payable {
uint pastBlockTime_36;
require(msg.value == 10 ether);
require(now != pastBlockTime_36);
pastBlockTime_36 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}