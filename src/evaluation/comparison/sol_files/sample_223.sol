pragma solidity ^0.8.0;
function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
return playerPendingWithdrawals[addressToCheck];
}