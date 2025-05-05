contract BondingCurve {
 uint256 public totalBonds;

 function issueBond (uint256 _bondAmount) public returns (uint) {
 	totalBonds = totalBonds + _bondAmount;
 	totalBonds = totalBonds - block.timestamp;
 	return totalBonds;
	}
}