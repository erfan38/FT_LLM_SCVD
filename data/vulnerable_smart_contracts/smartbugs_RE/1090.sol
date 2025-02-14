contract UnsafeAuction {
 address public highestBidder;
 uint public highestBid;

 function bid() public payable {
 require(msg.value > highestBid);
 address payable previousBidder = payable(highestBidder);
 uint previousBid = highestBid;
 highestBidder = msg.sender;
 highestBid = msg.value;
 previousBidder.call{value: previousBid}("");
 }
}