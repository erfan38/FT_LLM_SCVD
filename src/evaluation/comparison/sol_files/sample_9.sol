pragma solidity ^0.8.0;
function buyEther(uint256 amount) {
assert(valueToToken(etherContract,balances[msg.sender]) >= amount);
assert(destroyValue(msg.sender, tokenToValue(etherContract,amount)));
assert(msg.sender.call.value(amount)());
Buy(etherContract, msg.sender, amount, balances[msg.sender]);
}