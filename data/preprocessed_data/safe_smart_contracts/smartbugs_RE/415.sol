contract SafeLottery {
 address public winner;
 bool public gameEnded;

 function play() public payable {
 require(!gameEnded && msg.value == 1 ether);
 if (block.timestamp % 2 == 0) {
 gameEnded = true;
 winner = msg.sender;
 (bool success, ) = msg.sender.call{value: address(this).balance}("");
 require(success);
 }
 }
}