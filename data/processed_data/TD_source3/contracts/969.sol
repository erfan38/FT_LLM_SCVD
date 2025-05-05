contract BlockBasedVoting {
 uint256 public votingStart;
 uint256 public votingEnd;

 constructor(uint256 _duration) {
 votingStart = block.number;
 votingEnd = votingStart + _duration;
 }

 function canVote() public view returns (bool) {
 return block.number >= votingStart && block.number <= votingEnd;
 }
}