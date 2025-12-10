pragma solidity ^0.8.0;
function setPricingStrategy(PricingStrategy _pricingStrategy) onlyOwner {
pricingStrategy = _pricingStrategy;


if(!pricingStrategy.isPricingStrategy()) {
throw;
}
}