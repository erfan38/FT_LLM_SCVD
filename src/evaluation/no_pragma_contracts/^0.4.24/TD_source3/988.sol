contract TimedCrowdsale {
 uint256 public startTime;
 uint256 public endTime;

 constructor(uint256 _startTime, uint256 _endTime) {
 startTime = _startTime;
 endTime = _endTime;
 }

 function buyTokens() public payable {
 require(block.timestamp >= startTime && block.timestamp <= endTime, "Not within sale period");
 // Logic to issue tokens
 }
}