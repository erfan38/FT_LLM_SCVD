contract VotingPower {
 uint256 public basePower = 100;
 
 function calculateVotingPower(uint256 tokenBalance) public view returns (uint256) {
 return basePower * (block.number - tokenBalance);
 }
}