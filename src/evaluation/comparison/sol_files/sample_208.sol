pragma solidity ^0.8.0;
function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {
require(!safeGuard,"System Paused by Admin");
bytes32 hash = keccak256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
require((
(orders[user][hash] || ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),v,r,s) == user) &&
block.number <= expires &&
orderFills[user][hash].add(amount) <= amountGet
));
tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
orderFills[user][hash] = orderFills[user][hash].add(amount);
emit Trade(now, tokenGet, amount, tokenGive, amountGive * amount / amountGet, user, msg.sender);
}