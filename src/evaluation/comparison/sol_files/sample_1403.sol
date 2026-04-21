pragma solidity ^0.8.0;
function addAssetToOwnedAssets (address ofAsset)
public
pre_cond(isOwner() || msg.sender == address(this))
{
isInOpenMakeOrder[ofAsset] = true;
if (!isInAssetList[ofAsset]) {
ownedAssets.push(ofAsset);
isInAssetList[ofAsset] = true;
}
}