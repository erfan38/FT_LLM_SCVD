contract AuctionHouse {
 uint256 public auctionEndTime;
 address public highestBidder;
 uint256 public highestBid;

 function bid() public payable {
 require(block.timestamp < auctionEndTime, "Auction has ended");
 require(msg.value > highestBid, "Bid not high enough");
 highestBidder = msg.sender;
 highestBid = msg.value;
 }

 function endAuction() public {
 require(block.timestamp >= auctionEndTime, "Auction not yet ended");
 // Transfer item to highest bidder
 }
}