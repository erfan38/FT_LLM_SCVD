pragma solidity ^0.8.0;
function buyWithBonus(address inviter) validSale payable {

require( msg.sender != inviter );

uint tokens = safeMul(msg.value, fundAddress.price(block.timestamp));
uint bonus = safeDiv(safeMul(tokens, rate), 100);

fundAddress.buyRecipient.value(msg.value)(msg.sender);

totalSupply = safeAdd(totalSupply, bonus*2);

bonusBalances[inviter] = safeAdd(bonusBalances[inviter], bonus);
bonusBalances[msg.sender] = safeAdd(bonusBalances[msg.sender], bonus);
BuyWithBonus(msg.sender, inviter, msg.value, tokens, bonus);

}