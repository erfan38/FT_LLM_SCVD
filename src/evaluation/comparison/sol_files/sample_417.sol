pragma solidity ^0.8.0;
function changeStakeTokens(uint256 _NewTokensThreshold) public onlyOwner{
minstakeTokens = _NewTokensThreshold * 10 ** uint(10);
}