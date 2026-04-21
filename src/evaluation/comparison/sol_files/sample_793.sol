pragma solidity ^0.8.0;
function getTokensUnlockedPercentage () private view returns (uint256) {

uint256 allowedPercent;

for (uint8 i = 0; i < stages.length; i++) {
if (now >= stages[i].date) {
allowedPercent = stages[i].tokensUnlockedPercentage;
}
}

return allowedPercent;

}

}