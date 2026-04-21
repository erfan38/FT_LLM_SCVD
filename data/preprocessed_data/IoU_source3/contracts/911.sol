contract InflationaryToken {
 uint256 public totalSupply = 1000000;
 
 function calculateInflation() public view returns (uint256) {
 return totalSupply + (block.number * 10);
 }
}