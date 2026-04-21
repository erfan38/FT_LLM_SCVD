pragma solidity ^0.8.0;
function callOnExchange(
uint exchangeIndex,
bytes4 method,
address[5] orderAddresses,
uint[8] orderValues,
bytes32 identifier,
uint8 v,
bytes32 r,
bytes32 s
)
external
{
require(modules.pricefeed.exchangeMethodIsAllowed(
exchanges[exchangeIndex].exchange, method
));
require((exchanges[exchangeIndex].exchangeAdapter).delegatecall(
method, exchanges[exchangeIndex].exchange,
orderAddresses, orderValues, identifier, v, r, s
));
}

function addOpenMakeOrder(
address ofExchange,
address ofSellAsset,
uint orderId
)
pre_cond(msg.sender == address(this))
{
isInOpenMakeOrder[ofSellAsset] = true;
exchangesToOpenMakeOrders[ofExchange][ofSellAsset].id = orderId;
exchangesToOpenMakeOrders[ofExchange][ofSellAsset].expiresAt = add(now, ORDER_EXPIRATION_TIME);
}

function removeOpenMakeOrder(
address ofExchange,
address ofSellAsset
)
pre_cond(msg.sender == address(this))
{
delete exchangesToOpenMakeOrders[ofExchange][ofSellAsset];
}

function orderUpdateHook(
address ofExchange,
bytes32 orderId,
UpdateType updateType,
address[2] orderAddresses,
uint[3] orderValues
)
pre_cond(msg.sender == address(this))
{

if (updateType == UpdateType.make || updateType == UpdateType.take) {
orders.push(Order({
exchangeAddress: ofExchange,
orderId: orderId,
updateType: updateType,
makerAsset: orderAddresses[0],
takerAsset: orderAddresses[1],
makerQuantity: orderValues[0],
takerQuantity: orderValues[1],
timestamp: block.timestamp,
fillTakerQuantity: orderValues[2]
}));
}
emit OrderUpdated(ofExchange, orderId, updateType);
}









function calcGav() returns (uint gav) {

uint[] memory allAssetHoldings = new uint[](ownedAssets.length);
uint[] memory allAssetPrices = new uint[](ownedAssets.length);
address[] memory tempOwnedAssets;
tempOwnedAssets = ownedAssets;
delete ownedAssets;
for (uint i = 0; i < tempOwnedAssets.length; ++i) {
address ofAsset = tempOwnedAssets[i];

uint assetHoldings = add(
uint(AssetInterface(ofAsset).balanceOf(address(this))),
quantityHeldInCustodyOfExchange(ofAsset)
);

var (isRecent, assetPrice, assetDecimals) = modules.pricefeed.getPriceInfo(ofAsset);
if (!isRecent) {
revert();
}
allAssetHoldings[i] = assetHoldings;
allAssetPrices[i] = assetPrice;

gav = add(gav, mul(assetHoldings, assetPrice) / (10 ** uint256(assetDecimals)));
if (assetHoldings != 0 || ofAsset == address(QUOTE_ASSET) || isInOpenMakeOrder[ofAsset]) {
ownedAssets.push(ofAsset);
} else {
isInAssetList[ofAsset] = false;
}
}
emit PortfolioContent(tempOwnedAssets, allAssetHoldings, allAssetPrices);
}