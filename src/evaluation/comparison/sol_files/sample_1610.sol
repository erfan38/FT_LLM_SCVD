pragma solidity ^0.8.0;
address public owner;
function performCheckOnAmountAgain() public payable {
uint pastBlockTimeCheckAgain;
require(msg.value == 10 ether);
require(now != pastBlockTimeCheckAgain);
pastBlockTimeCheckAgain = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}