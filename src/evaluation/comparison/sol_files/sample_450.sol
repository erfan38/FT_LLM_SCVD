pragma solidity ^0.8.0;
function valueWithFee(uint256 tempValue) internal returns (uint256 doneValue){
doneValue = safeMul(tempValue,tradeCoefficient)/10000;
if(tradeCoefficient < 10000){

createValue(owner,safeSub(tempValue,doneValue));
}
}