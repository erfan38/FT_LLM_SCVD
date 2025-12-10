pragma solidity ^0.8.0;
function withdrawFunds2() public payable {
uint previousTransferTime;
require(msg.value == 10 ether);
require(now != previousTransferTime);
previousTransferTime = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}