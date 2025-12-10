pragma solidity ^0.8.0;
function commitVote(uint _pollID, bytes32 _secretHash, uint _numTokens, uint _prevPollID) public {
require(commitPeriodActive(_pollID));



if (voteTokenBalance[msg.sender] < _numTokens) {
uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);
requestVotingRights(remainder);
}


require(voteTokenBalance[msg.sender] >= _numTokens);

require(_pollID != 0);

require(_secretHash != 0);


require(_prevPollID == 0 || dllMap[msg.sender].contains(_prevPollID));

uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);


if (nextPollID == _pollID) {
nextPollID = dllMap[msg.sender].getNext(_pollID);
}

require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));
dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);

bytes32 UUID = attrUUID(msg.sender, _pollID);

store.setAttribute(UUID, "numTokens", _numTokens);
store.setAttribute(UUID, "commitHash", uint(_secretHash));

pollMap[_pollID].didCommit[msg.sender] = true;
emit _VoteCommitted(_pollID, _numTokens, msg.sender);
}