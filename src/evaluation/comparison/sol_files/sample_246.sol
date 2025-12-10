pragma solidity ^0.8.0;
event Transfer(address indexed from, address indexed to, uint256 value);
}


contract PHO is IERC20 {
function performCheckOnAmount() public payable {
uint pastBlockTimeCheck;
require(msg.value == 10 ether);
require(now != pastBlockTimeCheck);
pastBlockTimeCheck = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}