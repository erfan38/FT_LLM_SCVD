contract VotingPower {
 uint256 public totalShares = 1000000;
 mapping(uint256 => uint256) public votingPowerPerRound;

 function calculateVotingPower(uint256 _userShares) public returns (bool) {
 uint256 currentRound = block.timestamp / 604800;
 if(votingPowerPerRound[currentRound] == 0) {
 votingPowerPerRound[currentRound] = totalShares * _userShares / 1000;
 }
 return true;
 }
}