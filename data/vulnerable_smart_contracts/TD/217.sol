contract TimedAuction {
 uint256 public endTime;

 function isOpen() public view returns (bool) {
 return block.timestamp < endTime;
 }

 function bid() public payable {
 require(isOpen(), "Auction has ended");
 // Bidding logic
 }
}