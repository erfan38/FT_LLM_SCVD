pragma solidity ^0.8.0;
function calculateTotalSupply(uint256 _newTotalPot) private pure returns(uint256) {
return _newTotalPot.mul(10000000000000000000000000000)
.add(193600000000000000000000000000000000000000000000)
.sqrt()
.sub(440000000000000000000000);
}