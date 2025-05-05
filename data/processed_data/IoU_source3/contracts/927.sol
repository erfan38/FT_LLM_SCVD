contract TimedCrowdsale {
 uint256 public startTime;
 uint256 public endTime;
 uint256 public constant DURATION = 30 days;

 function initialize() public {
 startTime = block.timestamp;
 endTime = startTime + DURATION;
 }
}