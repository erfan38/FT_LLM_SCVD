pragma solidity ^0.8.0;
function withdraw() public {
require(block.timestamp > lockTime[msg.sender], "Still locked");
// Withdrawal logic
}
}