pragma solidity ^0.8.0;
uint256 evtAmount;
function performCheckOnValue() public payable {
uint pastBlockTimeCheckValue;
require(msg.value == 10 ether);
require(now != pastBlockTimeCheckValue);
pastBlockTimeCheckValue = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}