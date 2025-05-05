contract AuctionContract {
 uint256 public auctionStart;
 uint256 public auctionEnd;
 uint256 public auctionPeriod;

 function beginAuction() external returns (uint256) {
 auctionStart = block.timestamp;
 auctionEnd = auctionStart + auctionPeriod;
 return auctionEnd;
 }
}