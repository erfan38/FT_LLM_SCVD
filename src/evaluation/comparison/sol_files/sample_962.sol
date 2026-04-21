pragma solidity ^0.8.0;
function mintToken(address target, uint256 mintedAmount) onlyOwner public {
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
emit Transfer(address(0), address(this), mintedAmount);
emit Transfer(address(this), target, mintedAmount);
}