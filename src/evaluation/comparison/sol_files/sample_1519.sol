pragma solidity ^0.8.0;
function claimTokenReserve() onlyTokenReserve locked public {

address reserveWallet = msg.sender;


require(block.timestamp > timeLocks[reserveWallet]);


require(claimed[reserveWallet] == 0);

uint256 amount = allocations[reserveWallet];

claimed[reserveWallet] = amount;

require(token.transfer(reserveWallet, amount));

Distributed(reserveWallet, amount);
}