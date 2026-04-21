contract ReputationSystem {
 uint256 public initialReputation = 1000;
 
 function calculateReputation(uint256 activityLevel) public view returns (uint256) {
 return initialReputation + (block.timestamp * activityLevel);
 }
}