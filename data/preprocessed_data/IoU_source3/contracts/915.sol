contract TokenBurner {
 uint256 public totalSupply = 1000000;
 
 function burnTokens(uint256 amount) public returns (uint256) {
 totalSupply = totalSupply - amount;
 return totalSupply;
 }
}