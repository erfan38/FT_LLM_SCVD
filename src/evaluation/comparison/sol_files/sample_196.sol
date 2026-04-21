pragma solidity ^0.8.0;
function startPoll(uint _voteQuorum, uint _commitDuration, uint _revealDuration) public returns (uint pollID) {
pollNonce = pollNonce + 1;

uint commitEndDate = block.timestamp.add(_commitDuration);
uint revealEndDate = commitEndDate.add(_revealDuration);

pollMap[pollNonce] = Poll({
voteQuorum: _voteQuorum,
commitEndDate: commitEndDate,
revealEndDate: revealEndDate,
votesFor: 0,
votesAgainst: 0
});

emit _PollCreated(_voteQuorum, commitEndDate, revealEndDate, pollNonce, msg.sender);
return pollNonce;
}