pragma solidity ^0.8.0;
function amountOwed(address anAddress) public view returns (uint256) {
return creditRemaining[anAddress];
}