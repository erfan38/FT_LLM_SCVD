contract TimedMint {
 uint256 public lastMintTime;
 uint256 public constant MINT_COOLDOWN = 1 days;

 function mint() public {
 require(block.timestamp >= lastMintTime + MINT_COOLDOWN, "Cooldown not over");
 lastMintTime = block.timestamp;
 // Minting logic
 }
}