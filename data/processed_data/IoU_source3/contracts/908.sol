contract AuctionTimer {
 uint256 public auctionEndTime = 2000000000;
 
 function getTimeLeft() public view returns (uint256) {
 return auctionEndTime - block.timestamp;
 }
}