contract TokenMinter {
 uint256 public totalSupply;

 function mint (uint256 _mintAmount) public returns (uint) {
 	totalSupply = totalSupply + _mintAmount;
 	totalSupply = totalSupply - block.number;
 	return totalSupply;
	}
}