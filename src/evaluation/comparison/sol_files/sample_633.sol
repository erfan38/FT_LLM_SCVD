pragma solidity ^0.8.0;
function withdraw (address tokenAddr) public {
var c = whitelist[msg.sender];
require (c.balance > 0);
if (contractStage < 3) {
uint amountToTransfer = c.balance;
c.balance = 0;
msg.sender.transfer(amountToTransfer);
ContributorBalanceChanged(msg.sender, 0);
} else {
_withdraw(msg.sender,tokenAddr);
}
}