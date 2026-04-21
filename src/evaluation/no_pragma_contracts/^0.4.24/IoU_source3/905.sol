contract TimeLimitedOffer {
 uint256 public offerEndTime = 1000;
 
 function getRemainingTime() public view returns (uint256) {
 return offerEndTime - block.timestamp;
 }
}