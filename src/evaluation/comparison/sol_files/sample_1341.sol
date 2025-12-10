pragma solidity ^0.8.0;
function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {
bytes32 hash = sha256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
if (!(
(orders[user][hash] || ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash),v,r,s) == user) &&
block.number <= expires
)) return 0;
uint available1 = safeSub(amountGet, orderFills[user][hash]);
uint available2 = safeMul(tokens[tokenGive][user], amountGet) / amountGive;
if (available1<available2) return available1;
return available2;
}