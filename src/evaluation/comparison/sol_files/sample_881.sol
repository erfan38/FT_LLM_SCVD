pragma solidity ^0.8.0;
function markReleased() public {
if (isReleased == false && _now() > releaseTime) {
isReleased = true;
}
}