pragma solidity ^0.8.0;
function emergencyRedeem(uint shareQuantity, address[] requestedAssets)
public
pre_cond(balances[msg.sender] >= shareQuantity)
returns (bool)
{
address ofAsset;
uint[] memory ownershipQuantities = new uint[](requestedAssets.length);
address[] memory redeemedAssets = new address[](requestedAssets.length);


for (uint i = 0; i < requestedAssets.length; ++i) {
ofAsset = requestedAssets[i];
require(isInAssetList[ofAsset]);
for (uint j = 0; j < redeemedAssets.length; j++) {
if (ofAsset == redeemedAssets[j]) {
revert();
}
}
redeemedAssets[i] = ofAsset;
uint assetHoldings = add(
uint(AssetInterface(ofAsset).balanceOf(address(this))),
quantityHeldInCustodyOfExchange(ofAsset)
);

if (assetHoldings == 0) continue;


ownershipQuantities[i] = mul(assetHoldings, shareQuantity) / _totalSupply;


if (uint(AssetInterface(ofAsset).balanceOf(address(this))) < ownershipQuantities[i]) {
isShutDown = true;
emit ErrorMessage("CRITICAL ERR: Not enough assetHoldings for owed ownershipQuantitiy");
return false;
}
}


annihilateShares(msg.sender, shareQuantity);


for (uint k = 0; k < requestedAssets.length; ++k) {

ofAsset = requestedAssets[k];
if (ownershipQuantities[k] == 0) {
continue;
} else if (!AssetInterface(ofAsset).transfer(msg.sender, ownershipQuantities[k])) {
revert();
}
}
emit Redeemed(msg.sender, now, shareQuantity);
return true;
}