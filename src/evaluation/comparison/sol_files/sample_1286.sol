pragma solidity ^0.8.0;
function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {
bytes32 hash = keccak256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
orders[msg.sender][hash] = true;
emit Order(now, tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender);
}