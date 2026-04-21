contract TimedLottery {
 uint256 public drawTime;
 uint256 public ticketPrice = 0.1 ether;

 function buyTicket() public payable {
 require(msg.value == ticketPrice, "Incorrect ticket price");
 require(block.timestamp < drawTime, "Lottery closed");
 // Logic to assign ticket
 }

 function drawWinner() public {
 require(block.timestamp >= drawTime, "Too early to draw");
 // Logic to select winner
 }
}