pragma solidity ^0.8.0;
function pricesToCommit(address[] ofAssets)
view
returns (uint[])
{
address[] memory operators = getOperators();
uint[] memory newPrices = new uint[](ofAssets.length);
for (uint i = 0; i < ofAssets.length; i++) {
uint[] memory assetPrices = new uint[](operators.length);
for (uint j = 0; j < operators.length; j++) {
SimplePriceFeed feed = SimplePriceFeed(operators[j]);
var (price, timestamp) = feed.assetsToPrices(ofAssets[i]);
if (now > add(timestamp, VALIDITY)) {
continue;
}
assetPrices[j] = price;
}
newPrices[i] = medianize(assetPrices);
}
return newPrices;
}