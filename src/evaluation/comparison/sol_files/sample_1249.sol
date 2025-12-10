pragma solidity ^0.8.0;
function getTokensAmountAllowedToWithdraw (uint256 tokensUnlockedPercentage) private view returns (uint256) {
uint256 totalTokensAllowedToWithdraw = initialTokensBalance.mul(tokensUnlockedPercentage).div(100);
uint256 unsentTokensAmount = totalTokensAllowedToWithdraw.sub(tokensSent);
return unsentTokensAmount;
}