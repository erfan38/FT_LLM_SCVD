pragma solidity ^0.8.0;
function ownerTransferEther(address sendTo, uint amount) public
onlyOwner
{

contractBalance = safeSub(contractBalance, amount);

setMaxProfit();
if(!sendTo.send(amount)) throw;
LogOwnerTransfer(sendTo, amount);
}