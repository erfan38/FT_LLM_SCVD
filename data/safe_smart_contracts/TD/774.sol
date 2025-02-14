contract VotingSystem {
 uint256 public startTime;
 uint256 public endTime;
 mapping(address => bool) public hasVoted;

 constructor(uint256 _duration) {
 startTime = block.number;
 endTime = startTime + _duration;
 }

 function vote() public {
 require(block.number >= startTime && block.number <= endTime, "Voting is not active");
 require(!hasVoted[msg.sender], "Already voted");
 hasVoted[msg.sender] = true;
 // Record vote
 }
}