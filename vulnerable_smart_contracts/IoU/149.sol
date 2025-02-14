contract TokenMinter {
 uint256 public totalSupply;
 uint256 public constant MAX_SUPPLY = 1000000;

 function mintTokens(uint256 amount) public {
 totalSupply = totalSupply + amount;
 require(totalSupply <= MAX_SUPPLY, "Max supply reached");
 }
}