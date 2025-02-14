contract TimedMint {
 uint public lastMintTime;
 uint public mintInterval = 1 days;
 uint public mintAmount = 100;

 function mint() public {
 require(block.timestamp >= lastMintTime + mintInterval, "Too early to mint");
 lastMintTime = block.timestamp;
 // Mint mintAmount of tokens to msg.sender
 }

 function setMintInterval(uint _newInterval) public {
 mintInterval = _newInterval;
 }
}