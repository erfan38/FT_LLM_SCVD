pragma solidity ^0.8.0;
function isCompetitionActive() view returns (bool) { return now >= startTime && now < endTime; }