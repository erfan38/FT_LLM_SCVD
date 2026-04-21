contract TokenMultiplier {
 function multiplyTokens(uint _tokens, uint _multiplier) public pure returns (uint) {
 uint totalTokens = _tokens * _multiplier;
 return totalTokens;
 }
}