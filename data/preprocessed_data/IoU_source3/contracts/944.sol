contract VotingSystem {
 uint256 public votesFor;
 uint256 public votesAgainst;

 function calculatePercentage() public view returns (uint256) {
 return (votesFor * 100) / (votesFor + votesAgainst);
 }
}