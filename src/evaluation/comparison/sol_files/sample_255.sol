pragma solidity ^0.8.0;
function hasRecentPrice(address ofAsset)
view
pre_cond(assetIsRegistered(ofAsset))
returns (bool isRecent)
{
var ( , timestamp) = getPrice(ofAsset);
return (sub(now, timestamp) <= VALIDITY);
}