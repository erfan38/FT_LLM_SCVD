pragma solidity ^0.8.0;
function getTimeTillEnd() view returns (uint) {
if (now > endTime) {
return 0;
}
return sub(endTime, now);
}