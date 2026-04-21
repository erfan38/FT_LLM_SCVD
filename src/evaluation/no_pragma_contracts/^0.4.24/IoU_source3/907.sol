contract TokenVesting {
 uint256 public vestingStart = 1600000000;
 
 function getVestedAmount() public view returns (uint256) {
 uint256 vestingPeriod = block.timestamp - vestingStart;
 return vestingPeriod * 10;
 }
}