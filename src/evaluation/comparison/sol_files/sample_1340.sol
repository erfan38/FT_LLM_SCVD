pragma solidity ^0.8.0;
function withdraw(address user, bool has_fee) internal {

if (!bought_tokens) {

uint256 eth_to_withdraw = balances[user];

balances[user] = 0;

user.transfer(eth_to_withdraw);
}

else {

uint256 tokens_to_withdraw = balances[user] * tokens_per_eth;

balances[user] = 0;

uint256 fee = 0;

if (has_fee) {
fee = tokens_to_withdraw / 100;

if(!token.transfer(developer, fee)) throw;
}

if(!token.transfer(user, tokens_to_withdraw - fee)) throw;
}
}