contract TimedAuction {
 uint256 public auctionEndTime;
 address public highestBidder;
 uint256 public highestBid;

 constructor(uint256 _duration) {
 auctionEndTime = block.timestamp + _duration;
 }

 function bid() public payable {
 require(block.timestamp < auctionEndTime, "Auction has ended");
 require(msg.value > highestBid, "Bid not high enough");
 highestBidder = msg.sender;
 highestBid = msg.value;
 }

 function endAuction() public {
 require(block.timestamp >= auctionEndTime, "Auction not yet ended");
 // Transfer highest bid to seller
 }
}