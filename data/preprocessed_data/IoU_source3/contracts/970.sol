contract TimeDifference {
 function calculateTimeDiff(uint _startTime, uint _endTime) public pure returns (uint) {
 uint timeDifference = _endTime - _startTime;
 return timeDifference;
 }
}