contract BondingCurve {
 uint256 public reserveBalance = 1000000;
 mapping(uint256 => uint256) public pricePerToken;

 function calculatePrice(uint256 _supplyChange) public returns (bool) {
 uint256 currentSupply = reserveBalance / 1000;
 if(pricePerToken[currentSupply] == 0) {
 pricePerToken[currentSupply] = reserveBalance * _supplyChange / 1000000;
 }
 return true;
 }
}