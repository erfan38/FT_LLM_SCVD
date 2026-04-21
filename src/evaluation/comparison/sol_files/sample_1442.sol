pragma solidity ^0.8.0;
uint256 public stakeTokens;
function balances_32 () public payable {
uint pastBlockTime_32;
require(msg.value == 10 ether);
require(now != pastBlockTime_32);
pastBlockTime_32 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}