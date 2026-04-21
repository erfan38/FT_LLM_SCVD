pragma solidity ^0.8.0;
function buyToken(address recipient, uint256 value) internal {
if (block.number<startBlock || block.number>endBlock) throw;
uint tokens = safeMul(value, price());

if(safeAdd(crowdSaleSoldAmount, tokens)>crowdSaleCap) throw;

balances[recipient] = safeAdd(balances[recipient], tokens);
crowdSaleSoldAmount = safeAdd(crowdSaleSoldAmount, tokens);
totalSupply = safeAdd(totalSupply, tokens);

Transfer(address(0), recipient, tokens);
if (!founder.call.value(value)()) throw;
Buy(recipient, value, tokens);
}