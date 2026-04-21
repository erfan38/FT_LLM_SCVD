contract BondingCurve {
 uint256 public constant CURVE_EXPONENT = 2;
 
 function calculatePrice(uint256 supply) public pure returns (uint256) {
 return supply ** CURVE_EXPONENT;
 }
}