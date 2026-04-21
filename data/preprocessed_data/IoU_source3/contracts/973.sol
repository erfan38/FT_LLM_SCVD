contract VotingPower {
 function calculateVotingPower(uint _tokens, uint _multiplier) public pure returns (uint) {
 uint votingPower = _tokens * _multiplier;
 return votingPower;
 }
}