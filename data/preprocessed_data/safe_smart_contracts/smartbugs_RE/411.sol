contract SimpleLottery {
 address public winner;
 bool public gameEnded;

 function play() public payable {
 require(!gameEnded, "Game has ended");
 require(msg.value == 1 ether, "Must send 1 ether to play");
 if (block.timestamp % 2 == 0) {
 winner = msg.sender;
 gameEnded = true;
 (bool success, ) = msg.sender.call{value: address(this).balance}("");
 require(success, "Transfer failed");
 }
 }
}