pragma solidity ^0.8.0;
function requestInvestment(
uint giveQuantity,
uint shareQuantity,
address investmentAsset
)
external
pre_cond(!isShutDown)
pre_cond(isInvestAllowed[investmentAsset])
pre_cond(modules.compliance.isInvestmentPermitted(msg.sender, giveQuantity, shareQuantity))
{
requests.push(Request({
participant: msg.sender,
status: RequestStatus.active,
requestAsset: investmentAsset,
shareQuantity: shareQuantity,
giveQuantity: giveQuantity,
receiveQuantity: shareQuantity,
timestamp: now,
atUpdateId: modules.pricefeed.getLastUpdateId()
}));

emit RequestUpdated(getLastRequestId());
}





function executeRequest(uint id)
external
pre_cond(!isShutDown)
pre_cond(requests[id].status == RequestStatus.active)
pre_cond(
_totalSupply == 0 ||
(
now >= add(requests[id].timestamp, modules.pricefeed.getInterval()) &&
modules.pricefeed.getLastUpdateId() >= add(requests[id].atUpdateId, 2)
)
)

{
Request request = requests[id];
var (isRecent, , ) =
modules.pricefeed.getPriceInfo(address(request.requestAsset));
require(isRecent);


uint costQuantity = toWholeShareUnit(mul(request.shareQuantity, calcSharePriceAndAllocateFees()));
if (request.requestAsset != address(QUOTE_ASSET)) {
var (isPriceRecent, invertedRequestAssetPrice, requestAssetDecimal) = modules.pricefeed.getInvertedPriceInfo(request.requestAsset);
if (!isPriceRecent) {
revert();
}
costQuantity = mul(costQuantity, invertedRequestAssetPrice) / 10 ** requestAssetDecimal;
}

if (
isInvestAllowed[request.requestAsset] &&
costQuantity <= request.giveQuantity
) {
request.status = RequestStatus.executed;
require(AssetInterface(request.requestAsset).transferFrom(request.participant, address(this), costQuantity));
createShares(request.participant, request.shareQuantity);
if (!isInAssetList[request.requestAsset]) {
ownedAssets.push(request.requestAsset);
isInAssetList[request.requestAsset] = true;
}
} else {
revert();
}
}