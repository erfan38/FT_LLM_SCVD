contract TimedAuction {
 uint256 public auctionEnd;

 constructor(uint256 _duration) {
 auctionEnd = block.timestamp + _duration;
 }

 function bid() public payable {
 require(block.timestamp < auctionEnd, "Auction has ended");
 // Bidding logic here
 }
}