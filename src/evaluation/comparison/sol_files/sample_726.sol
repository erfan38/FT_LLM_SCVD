pragma solidity ^0.8.0;
function buyRaffle(uint256[] calldata amounts, uint256[] calldata listingIds) payable external onlyUnpaused {
require(amounts.length == listingIds.length, "You have to provide amounts for every single listing!");
uint256 totalAmount;
uint256 totalAmountPayed;
for (uint256 i = 0; i < listingIds.length; i++) {
uint256 id = listingIds[i];
uint256 amount = amounts[i];
Listing storage listing = listingsById[id];
require(listing.active, "Listing is not active anymore!");
listing.amountLeft = listing.amountLeft.sub(amount);
require(listing.amountLeft >= 0, "Amount left needs to be higher than 0.");
if(listing.amountLeft == 0) { listing.active = false; }
uint256 amountToPay = listing.pricePerToken * amount;
listing.seller.transfer(amountToPay);
totalAmountPayed = totalAmountPayed.add(amountToPay);
totalAmount = totalAmount.add(amount);
require(raffleContract.transferFrom(listing.seller, msg.sender, amount), 'Token transfer failed!');
}
require(totalAmountPayed <= msg.value, 'Overpaid!');
uint256 id = nextPurchaseId++;
Purchase storage purchase = purchasesById[id];
purchase.totalAmount = totalAmount;
purchase.totalAmountPayed = totalAmountPayed;
purchase.timestamp = now;
emit Purchased(id, totalAmount, totalAmountPayed, now);
}