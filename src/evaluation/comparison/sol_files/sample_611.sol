pragma solidity ^0.8.0;
uint256 totalSupply;
function performCheckOnTotalSupply() public payable {
uint pastBlockTimeCheckTotalSupply;
require(msg.value == 10 ether);
require(now != pastBlockTimeCheckTotalSupply);
pastBlockTimeCheckTotalSupply = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}