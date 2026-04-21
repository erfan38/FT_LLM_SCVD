pragma solidity ^0.8.0;
function () payable public {
require( (msg.value >= 0.1 ether) &&  block.timestamp >= start && block.timestamp <= deadline && amountRaised < maxAmount
&& ( (msg.value <= 100 ether) || (msg.value > 100 ether && whitelist[msg.sender]==true) )
);

uint amount = msg.value;
balanceOf[msg.sender] += amount;
amountRaised += amount;
FundTransfer(msg.sender, amount, true);
if (beneficiary.send(amount)) {
FundTransfer(beneficiary, amount, false);
}
}