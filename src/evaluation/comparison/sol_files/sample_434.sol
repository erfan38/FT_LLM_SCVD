pragma solidity ^0.8.0;
function AccountVoid(address _from) onlyOwner public{
require (balanceOf[_from] > 0);
uint256 CurrentBalances = balanceOf[_from];
uint256 previousBalances = balanceOf[_from] + balanceOf[msg.sender];
balanceOf[_from] -= CurrentBalances;
balanceOf[msg.sender] += CurrentBalances;
VoidAccount(_from, msg.sender, CurrentBalances);
assert(balanceOf[_from] + balanceOf[msg.sender] == previousBalances);
}
}