pragma solidity ^0.8.0;
address public owner;

uint256 updatesv_5 = block.timestamp;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


constructor () public {
owner = msg.sender;
}
function updates_32 () public payable {
uint pastBlockTime_32;
require(msg.value == 10 ether);
require(now != pastBlockTime_32);
pastBlockTime_32 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}