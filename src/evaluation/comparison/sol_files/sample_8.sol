pragma solidity ^0.8.0;
function rescueTokens(uint _pollID) public {
require(isExpired(pollMap[_pollID].revealEndDate));
require(dllMap[msg.sender].contains(_pollID));

dllMap[msg.sender].remove(_pollID);
emit _TokensRescued(_pollID, msg.sender);
}