contract VotingSystem {
 mapping(address => uint256) public votingPower;
 uint256 public constant POWER_MULTIPLIER = 100;

 function calculateVotingPower(address voter, uint256 tokens) public {
 votingPower[voter] = tokens * POWER_MULTIPLIER;
 }
}