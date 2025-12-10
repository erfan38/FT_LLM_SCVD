pragma solidity ^0.8.0;
contract TimedCrowdsale {
uint public startTime;
uint public endTime;

function setDuration(uint durationInDays) public {
startTime = block.timestamp;
endTime = startTime + durationInDays * 1 days;
}
}