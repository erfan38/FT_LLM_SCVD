pragma solidity ^0.8.0;
function()
payable
public
{

if(botPhase) {
revert();
} else {
purchaseInternal(msg.value, 0x0);
}

}





function payBankRoll() payable public {
uint256 ethToPay = SafeMath.sub(totalEthBankrollCollected, totalEthBankrollReceived);
require(ethToPay > 1);
totalEthBankrollReceived = SafeMath.add(totalEthBankrollReceived, ethToPay);
if(!giveEthBankRollAddress.call.value(ethToPay).gas(400000)()) {
totalEthBankrollReceived = SafeMath.sub(totalEthBankrollReceived, ethToPay);
}
}