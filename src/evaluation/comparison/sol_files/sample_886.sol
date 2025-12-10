pragma solidity ^0.8.0;
function updatePrice(uint256 _newTotalSupply) private {
price = _newTotalSupply.mul(2).div(10000000000).add(88000000000000);
uint256 _idx = feeIndex + 1;
while (_idx < feePrices.length && price >= feePrices[_idx]) {
feeIndex = _idx;
++_idx;
}
}