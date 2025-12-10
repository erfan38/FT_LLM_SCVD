pragma solidity ^0.8.0;
function getTotalNumberOfTokensForWinningOption(uint _pollID) constant public returns (uint numTokens) {
require(pollEnded(_pollID));

if (isPassed(_pollID))
return pollMap[_pollID].votesFor;
else
return pollMap[_pollID].votesAgainst;
}