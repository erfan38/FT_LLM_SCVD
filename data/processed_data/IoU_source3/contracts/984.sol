contract AuctionHouse {
 uint public highestBid;

 function placeBid() public payable {
 require(msg.value > highestBid, "Bid too low");
 highestBid = msg.value;
 }
}