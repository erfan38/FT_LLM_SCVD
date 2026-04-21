contract AuctionHouse {
 uint256 public highestBid;
 uint256 public constant BID_INCREMENT = 1 ether;

 function placeBid() public payable {
 require(msg.value >= highestBid + BID_INCREMENT, "Bid too low");
 highestBid = msg.value;
 }
}