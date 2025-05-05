contract TokenMinter {
 uint public totalTokens = 1000;

 function mint(uint amount) public returns (uint) {
 totalTokens = totalTokens + amount;
 return totalTokens;
 }
}