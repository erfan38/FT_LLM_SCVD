pragma solidity ^0.8.0;
function initializeVestingFor (address account) external deployerOnly whenNotInitialized {
initialTokensBalance = dreamToken.balanceOf(this);
require(initialTokensBalance != 0);
withdrawalAddress = account;
vestingStartUnixTimestamp = block.timestamp;
vestingRules();
}