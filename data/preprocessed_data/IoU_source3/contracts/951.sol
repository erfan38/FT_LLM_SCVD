contract Auction {
 uint256 public highestBid;

 function placeBid(uint256 bidAmount) public returns (bool) {
 if (bidAmount > highestBid) {
 highestBid = bidAmount;
 return true;
 }
 return false;
 }
}