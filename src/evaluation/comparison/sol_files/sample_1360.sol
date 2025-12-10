pragma solidity ^0.8.0;
function withdraw() public {
require(block.timestamp > lockTime[msg.sender], "Lock time not expired");
// Withdrawal logic here
}
}