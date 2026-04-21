pragma solidity ^0.8.0;
function issueTokensMultiple(uint256[] _transactionIds, uint256[] bonusTokensAmounts) public onlyOwner {
require(isFinalized);
require(_transactionIds.length == bonusTokensAmounts.length);
for (uint i = 0; i < _transactionIds.length; i++) {
issueTokens(_transactionIds[i], bonusTokensAmounts[i]);
}
}