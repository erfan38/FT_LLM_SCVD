contract BondingCurve {
 uint256 public constant EXPONENT = 2;
 uint256 public tokenSupply;

 function calculatePrice(uint256 amount) public view returns (uint256) {
 return (tokenSupply + amount) ** EXPONENT - tokenSupply ** EXPONENT;
 }
}