pragma solidity ^0.8.0;
function validPurchase() internal view returns (bool) {

bool minValue = msg.value >= 100000000000000000;


bool maxValue = msg.value <= 1000000000000000000000;


return

minValue &&


maxValue &&

super.validPurchase();
}