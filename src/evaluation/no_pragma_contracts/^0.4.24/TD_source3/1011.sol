contract SimpleLottery {
 uint public lastDrawTime;
 uint public constant DRAW_INTERVAL = 7 days;

 function enterLottery() public payable {
 // entry logic here
 }

 function drawWinner() public {
 require(block.timestamp >= lastDrawTime + DRAW_INTERVAL, "Too early for next draw");
 lastDrawTime = block.timestamp;
 // winner selection logic here
 }
}