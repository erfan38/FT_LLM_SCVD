pragma solidity ^0.8.0;
function calcPurchase(uint _wei, uint _t) internal view returns (uint weiPerToken, uint tokens, uint refund)
{
require(_t >= lastPurchaseTick);
uint numTicks = _t - lastPurchaseTick;
if (isInitialAuctionEnded()) {
weiPerToken = priceAt(lastPurchasePrice, numTicks);
} else {
weiPerToken = priceAtInitialAuction(lastPurchasePrice, numTicks);
}

uint calctokens = METDECMULT.mul(_wei).div(weiPerToken);
tokens = calctokens;
if (calctokens > mintable) {
tokens = mintable;
uint ethPaying = mintable.mul(weiPerToken).div(METDECMULT);
refund = _wei.sub(ethPaying);
}
}