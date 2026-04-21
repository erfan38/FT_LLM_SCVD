pragma solidity ^0.8.0;
function revealPeriodActive(uint _pollID) constant public returns (bool active) {
require(pollExists(_pollID));

return !isExpired(pollMap[_pollID].revealEndDate) && !commitPeriodActive(_pollID);
}