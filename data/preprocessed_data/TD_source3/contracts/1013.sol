contract AuctionHouse {
 uint public auctionEndTime;

 function startAuction(uint _duration) public {
 auctionEndTime = block.timestamp + _duration;
 }

 function bid() public payable {
 require(block.timestamp < auctionEndTime, "Auction has ended");
 // bidding logic here
 }

 function endAuction() public {
 require(block.timestamp >= auctionEndTime, "Auction not yet ended");
 // auction ending logic here
 }
}