pragma solidity ^0.8.0;
function getCrowdsaleUserCap() public view returns (uint256) {
require(block.timestamp >= CROWDSALE_OPENING_TIME && block.timestamp <= CROWDSALE_CLOSING_TIME);

uint256 elapsedTime = block.timestamp.sub(CROWDSALE_OPENING_TIME);
uint256 currentMinElapsedTime = 0;
uint256 currentCap = 0;

for (uint i = 0; i < crowdsaleUserCaps.length; i++) {
if (elapsedTime < crowdsaleMinElapsedTimeLevels[i]) continue;
if (crowdsaleMinElapsedTimeLevels[i] < currentMinElapsedTime) continue;
currentCap = crowdsaleUserCaps[i];
}

return currentCap;
}