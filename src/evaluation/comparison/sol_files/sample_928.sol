pragma solidity ^0.8.0;
function cancelListing(uint256 id) external {
Listing storage listing = listingsById[id];
require(listing.active, "This listing was turned inactive already!");
require(listing.seller == msg.sender || owner == msg.sender, "Only the listing owner or the contract owner can cancel the listing!");
listing.active = false;
emit Canceled(id);
}