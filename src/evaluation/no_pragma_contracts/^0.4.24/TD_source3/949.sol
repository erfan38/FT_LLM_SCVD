contract VotingSystem {
 mapping(address => bool) public hasVoted;
 uint public votingStart;
 uint public votingEnd;

 constructor(uint _duration) {
 votingStart = block.number;
 votingEnd = votingStart + _duration;
 }

 function vote() public {
 require(block.number >= votingStart && block.number <= votingEnd, "Voting is not active");
 require(!hasVoted[msg.sender], "Already voted");
 hasVoted[msg.sender] = true;
 }
}