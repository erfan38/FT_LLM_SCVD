contract TokenBurner {
 uint256 public totalSupply;
 uint256 public constant BURN_RATE = 5;

 function burnTokens(uint256 amount) public {
 uint256 burnAmount = (amount * BURN_RATE) / 100;
 totalSupply = totalSupply - burnAmount;
 }
}