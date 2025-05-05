contract TokenBurner {
 uint public totalTokens = 1000000;

 function burnTokens(uint amount) public returns (uint) {
 totalTokens = totalTokens - amount;
 return totalTokens;
 }
}