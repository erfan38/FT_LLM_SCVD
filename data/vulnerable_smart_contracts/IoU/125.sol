contract TokenMinter {
 uint256 public circulatingSupply;

 function mintTokens (uint256 _mintAmount) public returns (uint) {
 	circulatingSupply = circulatingSupply + _mintAmount;
 	circulatingSupply = circulatingSupply - block.timestamp;
 	return circulatingSupply;
	}
}