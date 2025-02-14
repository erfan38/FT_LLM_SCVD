contract TokenSale {
 uint256 public saleEndTime;
 uint256 public tokenPrice;

 constructor(uint256 _duration) {
 saleEndTime = block.timestamp + _duration;
 }

 function buyTokens() public payable {
 require(block.timestamp < saleEndTime, "Sale has ended");
 uint256 tokens = msg.value / tokenPrice;
 // Transfer tokens to buyer
 }
}