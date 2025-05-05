contract TokenBurner {
 uint256 public circulatingSupply;

 function burnTokens (uint256 _burnAmount) public returns (uint) {
 	circulatingSupply = circulatingSupply - _burnAmount;
 	circulatingSupply = circulatingSupply + block.timestamp;
 	return circulatingSupply;
	}
}