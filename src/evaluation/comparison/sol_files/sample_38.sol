pragma solidity ^0.8.0;
function orderExpired(address ofExchange, address ofAsset) view returns (bool) {
uint expiryTime = exchangesToOpenMakeOrders[ofExchange][ofAsset].expiresAt;
require(expiryTime > 0);
return block.timestamp >= expiryTime;
}