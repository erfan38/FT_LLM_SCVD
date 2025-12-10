pragma solidity ^0.8.0;
function createShares(address recipient, uint shareQuantity) internal {
_totalSupply = add(_totalSupply, shareQuantity);
balances[recipient] = add(balances[recipient], shareQuantity);
emit Created(msg.sender, now, shareQuantity);
emit Transfer(address(0), recipient, shareQuantity);
}