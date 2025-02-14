contract TokenMinter {
 uint256 public totalSupply;
 uint256 public constant MINT_AMOUNT = 1000;

 function mint() public {
 totalSupply = totalSupply + MINT_AMOUNT;
 }
}