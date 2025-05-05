contract TimedLottery {
 uint256 public lastDrawTime;
 uint256 public drawInterval = 1 days;

 function drawWinner() public {
 require(block.timestamp >= lastDrawTime + drawInterval, "Too early for next draw");
 lastDrawTime = block.timestamp;
 // Winner selection logic here
 }
}