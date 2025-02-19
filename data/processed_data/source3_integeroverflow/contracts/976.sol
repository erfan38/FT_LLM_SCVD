contract TokenSplitter {
 function splitTokens(uint _totalTokens, uint _splits) public pure returns (uint) {
 uint tokensPerSplit = _totalTokens / _splits;
 return tokensPerSplit;
 }
}