contract TokenBurner {
 uint256 public totalSupply;

 function burnTokens(uint256 amount) public returns (uint256) {
 totalSupply = totalSupply - amount;
 return totalSupply;
 }
}