contract TimestampAdder {
 uint256 public latestTimestamp;

 function addSeconds(uint256 _seconds) external {
 latestTimestamp = block.timestamp + _seconds;
 }
}