pragma solidity ^0.8.0;
function validPurchase(uint256 weiAmount) internal view returns (bool) {
bool withinCap = weiRaised.add(weiAmount) <= hardCap;
bool withinCrowdsaleInterval = now >= startTime && now <= endTime;
return withinCrowdsaleInterval && withinCap;
}