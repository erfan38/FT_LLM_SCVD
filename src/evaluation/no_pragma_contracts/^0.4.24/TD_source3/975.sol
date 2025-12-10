contract TimedMint {
 uint256 public lastMintTime;
 uint256 public constant MINT_COOLDOWN = 1 hours;

 function mint() public {
 require(block.timestamp >= lastMintTime + MINT_COOLDOWN, "Minting is on cooldown");
 lastMintTime = block.timestamp;
 // Minting logic here
 }
}