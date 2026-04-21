pragma solidity ^0.8.0;
function submitPool (uint amountInWei) public onlyOwner noReentrancy {
require (contractStage == 1);
require (receiverAddress != 0x00);
require (block.number >= addressChangeBlock.add(6000));
if (amountInWei == 0) amountInWei = this.balance;
require (contributionMin <= amountInWei && amountInWei <= this.balance);
finalBalance = this.balance;
require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
if (this.balance > 0) ethRefundAmount.push(this.balance);
contractStage = 2;
PoolSubmitted(receiverAddress, amountInWei);
}