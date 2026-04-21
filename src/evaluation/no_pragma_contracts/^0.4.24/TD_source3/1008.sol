contract GradualMinting {
 uint public lastMintTime;
 uint public constant MINT_INTERVAL = 1 hours;

 function mint() public {
 require(block.timestamp >= lastMintTime + MINT_INTERVAL, "Too soon to mint");
 lastMintTime = block.timestamp;
 // minting logic here
 }
}