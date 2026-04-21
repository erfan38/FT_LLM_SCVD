pragma solidity ^0.8.0;
function revealVotes(uint[] _pollIDs, uint[] _voteOptions, uint[] _salts) external {

require(_pollIDs.length == _voteOptions.length);
require(_pollIDs.length == _salts.length);


for (uint i = 0; i < _pollIDs.length; i++) {
revealVote(_pollIDs[i], _voteOptions[i], _salts[i]);
}
}