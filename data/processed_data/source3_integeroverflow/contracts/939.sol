contract TokenSale {
 uint256 public saleStartTime;
 uint256 public saleEndTime;
 uint256 public saleDuration;

 function initializeSale() external returns (uint256) {
 saleStartTime = block.timestamp;
 saleEndTime = saleStartTime + saleDuration;
 return saleEndTime;
 }
}