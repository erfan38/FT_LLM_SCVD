pragma solidity ^0.8.0;
function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public
onlyOwner
{

maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);

if(!sendTo.send(originalPlayerBetValue)) throw;

LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);
}