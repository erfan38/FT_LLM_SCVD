contract UnsafeAuction {
 address public highestBidder;
 uint256 public highestBid;

 function bid() public payable {
 require(msg.value > highestBid, "Bid not high enough");
 address payable previousBidder = payable(highestBidder);
 uint256 previousBid = highestBid;
 highestBidder = msg.sender;
 highestBid = msg.value;
 (bool success, ) = previousBidder.call{value: previousBid}("");
 require(success, "Refund failed");
 }
}