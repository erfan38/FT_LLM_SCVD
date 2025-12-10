pragma solidity ^0.8.0;
function withdrawFees(uint amount) public onlyFeeAccount {
require(collectedFee >= amount);
collectedFee = SafeMath.safeSub(collectedFee, amount);
require(feeAccount.send(amount));
}