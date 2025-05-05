contract LiquidityPool {
 uint256 public totalLiquidity;

 function removeLiquidity (uint256 _amount) public returns (uint) {
 	totalLiquidity = totalLiquidity - _amount;
 	totalLiquidity = totalLiquidity + block.number;
 	return totalLiquidity;
	}
}