pragma solidity ^0.8.0;
function _updatePrices(address[] ofAssets, uint[] newPrices)
internal
pre_cond(ofAssets.length == newPrices.length)
{
updateId++;
for (uint i = 0; i < ofAssets.length; ++i) {
require(registrar.assetIsRegistered(ofAssets[i]));
require(assetsToPrices[ofAssets[i]].timestamp != now);
assetsToPrices[ofAssets[i]].timestamp = now;
assetsToPrices[ofAssets[i]].price = newPrices[i];
}
emit PriceUpdated(keccak256(ofAssets, newPrices));
}