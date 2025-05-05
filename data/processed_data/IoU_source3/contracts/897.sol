contract InflationaryToken {
 uint256 public tokenSupply;

 function inflate (uint256 _inflationRate) public returns (uint) {
 	tokenSupply = tokenSupply + _inflationRate;
 	tokenSupply = tokenSupply - block.number;
 	return tokenSupply;
	}
}