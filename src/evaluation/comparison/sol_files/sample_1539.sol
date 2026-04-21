pragma solidity ^0.8.0;
function buyForFriend(address friend) validSale payable {

require( msg.sender != friend );

uint tokens = safeMul(msg.value, fundAddress.price(block.timestamp));
uint bonus = safeDiv(safeMul(tokens, rate), 100);

fundAddress.buyRecipient.value(msg.value)(friend);

totalSupply = safeAdd(totalSupply, bonus*2);

bonusBalances[friend] = safeAdd(bonusBalances[friend], bonus);
bonusBalances[msg.sender] = safeAdd(bonusBalances[msg.sender], bonus);
BuyForFriend(msg.sender, friend, msg.value, tokens, bonus);

}