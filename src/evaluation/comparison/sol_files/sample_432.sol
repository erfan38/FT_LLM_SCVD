pragma solidity ^0.8.0;
function calculateInterest() public view returns (uint256) {
uint256 timeElapsed = block.timestamp - depositTime[msg.sender];
return balance[msg.sender] * timeElapsed / (365 days) * 5 / 100; // 5% annual interest
}
}