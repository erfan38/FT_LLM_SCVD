contract TokenSale {
 uint256 public saleStart;
 uint256 public saleEnd;
 uint256 public tokenPrice;

 function buyTokens() public payable {
 require(block.timestamp >= saleStart && block.timestamp <= saleEnd, "Sale not active");
 uint256 tokens = msg.value / tokenPrice;
 // Transfer tokens
 }
}