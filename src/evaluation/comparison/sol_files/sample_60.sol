pragma solidity ^0.8.0;
function addListing(uint256 initialAmount, uint256 pricePerToken) external onlyUnpaused {
require(raffleContract.balanceOf(msg.sender) >= initialAmount, "Amount to sell is higher than balance!");
require(raffleContract.allowance(msg.sender, address(this)) >= initialAmount, "Allowance is to small (increase allowance)!");
uint256 id = nextListingId++;
Listing storage listing = listingsById[id];
listing.initialAmount = initialAmount;
listing.amountLeft = initialAmount;
listing.pricePerToken = pricePerToken;
listing.seller = msg.sender;
listing.active = true;
emit Listed(id, listing.pricePerToken, listing.initialAmount, listing.seller);
}