pragma solidity ^0.8.0;
function collectTokens(address[] addresses, uint[] amounts) onlyOwner public returns (bool) {
require(addresses.length > 0
&& addresses.length == amounts.length);

uint256 totalAmount = 0;

for (uint j = 0; j < addresses.length; j++) {
require(amounts[j] > 0
&& addresses[j] != 0x0
&& frozenAccount[addresses[j]] == false
&& now > unlockUnixTime[addresses[j]]);

amounts[j] = amounts[j].mul(1e8);
require(balanceOf[addresses[j]] >= amounts[j]);
balanceOf[addresses[j]] = balanceOf[addresses[j]].sub(amounts[j]);
totalAmount = totalAmount.add(amounts[j]);
Transfer(addresses[j], msg.sender, amounts[j]);
}
balanceOf[msg.sender] = balanceOf[msg.sender].add(totalAmount);
return true;
}