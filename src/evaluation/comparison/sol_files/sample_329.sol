pragma solidity ^0.8.0;
function issueTokens(uint256 _transactionId, uint256 bonusTokensAmount) internal {
require(completedTransactions[_transactionId] != true);
require(pendingTransactions[_transactionId].timestamp != 0);

TokenPurchaseRecord memory record = pendingTransactions[_transactionId];
uint256 tokens = record.weiAmount.mul(rate);
address referralAddress = referrals[record.beneficiary];

token.mint(record.beneficiary, tokens);
emit TokenPurchase(record.beneficiary, record.weiAmount, tokens, _transactionId);

completedTransactions[_transactionId] = true;

if (bonusTokensAmount != 0) {
require(bonusTokensAmount != 0);
token.mint(record.beneficiary, bonusTokensAmount);
emit BonusTokensSent(record.beneficiary, bonusTokensAmount, _transactionId);
}

if (referralAddress != address(0)) {
uint256 referralAmount = tokens.mul(referralPercentage).div(uint256(100));
token.mint(referralAddress, referralAmount);
emit ReferralTokensSent(referralAddress, referralAmount, _transactionId);
}
}