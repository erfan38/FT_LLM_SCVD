contract TimeBoundVoting {
 uint256 public votingStart;
 uint256 public votingEnd;
 mapping(address => bool) public hasVoted;
 uint256 public yesVotes;
 uint256 public noVotes;

 constructor(uint256 _duration) {
 votingStart = block.timestamp;
 votingEnd = votingStart + _duration;
 }

 function vote(bool _vote) public {
 require(block.timestamp >= votingStart && block.timestamp <= votingEnd, "Voting is not active");
 require(!hasVoted[msg.sender], "Already voted");
 hasVoted[msg.sender] = true;
 if (_vote) yesVotes++; else noVotes++;
 }
}