pragma solidity ^0.8.0;
function commitPeriodActive(uint _pollID) constant public returns (bool active) {
require(pollExists(_pollID));

return !isExpired(pollMap[_pollID].commitEndDate);
}