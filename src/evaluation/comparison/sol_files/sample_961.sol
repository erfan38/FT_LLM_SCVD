pragma solidity ^0.8.0;
function getDecimals(address ofAsset) view returns (uint) { return assetInformation[ofAsset].decimals; }