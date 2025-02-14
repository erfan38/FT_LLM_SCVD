contract Auction {
 uint public auctionEnd;
 address public highestBidder;
 uint public highestBid;

 constructor(uint _biddingTime) {
 auctionEnd = block.timestamp + _biddingTime;
 }

 function bid() public payable {
 require(block.timestamp <= auctionEnd, "Auction ended");
 require(msg.value > highestBid, "Bid not high enough");
 highestBidder = msg.sender;
 highestBid = msg.value;
 }
}