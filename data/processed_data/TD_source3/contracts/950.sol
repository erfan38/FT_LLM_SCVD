contract DailyLottery {
 uint public lastDrawTime;
 address public winner;

 function draw() public {
 require(block.timestamp >= lastDrawTime + 1 days, "Too early for next draw");
 winner = msg.sender;
 lastDrawTime = block.timestamp;
 }
}