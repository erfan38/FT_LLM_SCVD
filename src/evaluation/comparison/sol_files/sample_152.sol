pragma solidity ^0.8.0;
function annihilateShares(address recipient, uint shareQuantity) internal {
_totalSupply = sub(_totalSupply, shareQuantity);
balances[recipient] = sub(balances[recipient], shareQuantity);
emit Annihilated(msg.sender, now, shareQuantity);
emit Transfer(recipient, address(0), shareQuantity);
}