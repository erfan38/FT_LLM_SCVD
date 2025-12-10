pragma solidity ^0.8.0;
function()
payable
public
{

require(tx.gasprice <= 0.05 szabo);
purchaseTokens(msg.value, 0x0);
}





function payFund() payable public
onlyAdministrator()
{


uint256 _bondEthToPay = 0;

uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
require(ethToPay > 1);

uint256 altEthToPay = SafeMath.div(SafeMath.mul(ethToPay,altFundFee_),100);
if (altFundFee_ > 0){
_bondEthToPay = SafeMath.sub(ethToPay,altEthToPay);
} else{
_bondEthToPay = 0;
}


totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
if(!bondFundAddress.call.value(_bondEthToPay).gas(400000)()) {
totalEthFundRecieved = SafeMath.sub(totalEthFundRecieved, _bondEthToPay);
}

if(altEthToPay > 0){
if(!altFundAddress.call.value(altEthToPay).gas(400000)()) {
totalEthFundRecieved = SafeMath.sub(totalEthFundRecieved, altEthToPay);
}
}

}