contract AuctionHouse {
 uint256 public auctionEnd;
 address public highestBidder;
 uint256 public highestBid;

 function bid() public payable {
 require(block.timestamp < auctionEnd, "Auction ended");
 require(msg.value > highestBid, "Bid too low");
 highestBidder = msg.sender;
 highestBid = msg.value;
 }

 function endAuction() public {
 require(block.timestamp >= auctionEnd, "Auction not yet ended");
 // Transfer logic
 }
}