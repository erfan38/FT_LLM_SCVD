pragma solidity ^0.8.0;
function finish() onlyOwner public {
require(block.timestamp >= finishTime);
feeOwner.transfer(address(this).balance);
}