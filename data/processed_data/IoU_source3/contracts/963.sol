contract TimeTravel {
 function futureDate(uint _days, uint _hours) public view returns (uint) {
 uint futureTimestamp = block.timestamp;
 futureTimestamp += _days * 86400;
 futureTimestamp += _hours * 3600;
 return futureTimestamp;
 }
}