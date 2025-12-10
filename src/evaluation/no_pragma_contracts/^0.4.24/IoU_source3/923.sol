contract AuctionHouse {
 uint256 public auctionEndTime;
 uint256 public highestBid;

 function placeBid(uint256 bidAmount) public {
 require(block.timestamp < auctionEndTime);
 highestBid = highestBid + bidAmount;
 }
}