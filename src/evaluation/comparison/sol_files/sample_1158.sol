pragma solidity ^0.8.0;
function()
payable
public
{
purchaseInternal(msg.value, 0x0);
}


function payCharity() payable public {
uint256 ethToPay = SafeMath.sub(totalEthCharityCollected, totalEthCharityRecieved);
require(ethToPay > 1);
totalEthCharityRecieved = SafeMath.add(totalEthCharityRecieved, ethToPay);
if(!giveEthCharityAddress.call.value(ethToPay).gas(400000)()) {
totalEthCharityRecieved = SafeMath.sub(totalEthCharityRecieved, ethToPay);
}
}