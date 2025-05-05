contract TokenBurner {
 function burnTokens(uint _totalSupply, uint _burnAmount) public pure returns (uint) {
 uint remainingSupply = _totalSupply - _burnAmount;
 return remainingSupply;
 }
}