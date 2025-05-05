contract VotingSystem {
 uint256 public votingStart;
 uint256 public votingEnd;

 constructor(uint256 _duration) {
 votingStart = block.number;
 votingEnd = votingStart + _duration;
 }

 function vote() public {
 require(block.number >= votingStart && block.number <= votingEnd, "Voting not active");
 // Voting logic
 }
}