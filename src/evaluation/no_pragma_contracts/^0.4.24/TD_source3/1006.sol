contract DailyLottery {
 uint256 public lastDrawTime;

 function draw() public {
 require(block.timestamp >= lastDrawTime + 1 days, "It's not time for the draw yet");
 lastDrawTime = block.timestamp;
 uint256 winningNumber = uint256(keccak256(abi.encodePacked(block.timestamp))) % 100;
 // Determine winners based on winningNumber
 }
}