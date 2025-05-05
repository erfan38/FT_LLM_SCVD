contract TimeBoundLottery {
 uint256 public drawTime;
 address[] public participants;

 constructor(uint256 _duration) {
 drawTime = block.timestamp + _duration;
 }

 function enter() public payable {
 require(block.timestamp < drawTime, "Lottery closed");
 require(msg.value == 0.1 ether, "Incorrect entry fee");
 participants.push(msg.sender);
 }

 function drawWinner() public {
 require(block.timestamp >= drawTime, "Too early to draw");
 // Logic to select winner
 }
}