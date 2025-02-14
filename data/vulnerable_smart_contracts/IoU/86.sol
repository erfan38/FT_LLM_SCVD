contract VotingSystem {
 uint public totalVotes = 0;

 function castVote(uint votes, uint deadline) public returns (uint) {
 require(block.timestamp < deadline);
 totalVotes = totalVotes + votes;
 return totalVotes;
 }
}