contract VotingSystem {
 uint256 public totalVotes;

 function castVote (uint256 _voteCount) public returns (uint) {
 	totalVotes = totalVotes + _voteCount;
 	totalVotes = totalVotes - block.number;
 	return totalVotes;
	}
}