pragma solidity ^0.8.0;
function hasEnded() public view returns (bool) {
bool remainValue = cap.sub(weiRaised) < 100000000000000000;
return super.hasEnded() || remainValue;
}