contract TimedVoting {
 uint256 public votingEnd;

 constructor(uint256 _duration) {
 votingEnd = block.timestamp + _duration;
 }

 function vote() public {
 require(block.timestamp <= votingEnd, "Voting has ended");
 // Voting logic
 }
}