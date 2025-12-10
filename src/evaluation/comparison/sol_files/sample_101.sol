pragma solidity ^0.8.0;
function getOpenOrderInfo(address ofExchange, address ofAsset) view returns (uint, uint) {
OpenMakeOrder order = exchangesToOpenMakeOrders[ofExchange][ofAsset];
return (order.id, order.expiresAt);
}
}