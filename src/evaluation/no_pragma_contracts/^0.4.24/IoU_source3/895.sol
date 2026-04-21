contract ReputationSystem {
 uint256 public totalReputation;

 function updateReputation (uint256 _repChange) public returns (uint) {
 	totalReputation = totalReputation + _repChange;
 	totalReputation = totalReputation - block.number;
 	return totalReputation;
	}
}