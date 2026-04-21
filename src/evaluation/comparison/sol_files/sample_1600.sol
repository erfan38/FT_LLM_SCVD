pragma solidity ^0.8.0;
function allocateFounderTokens() onlyAdmin {
require( block.timestamp > endDatetime );
require(!founderAllocated);

balances[founder] = safeAdd(balances[founder], founderAllocation);
totalSupply = safeAdd(totalSupply, founderAllocation);
founderAllocated = true;

AllocateFounderTokens(msg.sender, founderAllocation);
}