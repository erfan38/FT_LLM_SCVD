contract SquareCalculator {
 function square(uint128 x) public pure returns (uint256) {
 return uint256(x) * uint256(x);
 }
}