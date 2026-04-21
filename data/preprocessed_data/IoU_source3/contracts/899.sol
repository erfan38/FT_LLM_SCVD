contract VotingPower {
 uint256 public totalPower;

 function updatePower (uint256 _powerChange) public returns (uint) {
 	totalPower = totalPower + _powerChange;
 	totalPower = totalPower - block.number;
 	return totalPower;
	}
}