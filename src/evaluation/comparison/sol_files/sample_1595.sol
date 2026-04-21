pragma solidity ^0.8.0;
function getReferencePriceInfo(address ofBase, address ofQuote)
view
returns (bool isRecent, uint referencePrice, uint decimal)
{
if (getQuoteAsset() == ofQuote) {
(isRecent, referencePrice, decimal) = getPriceInfo(ofBase);
} else if (getQuoteAsset() == ofBase) {
(isRecent, referencePrice, decimal) = getInvertedPriceInfo(ofQuote);
} else {
revert();
}
}