pragma solidity ^0.8.0;
function whichTick(uint t) public view returns(uint) {
if (genesisTime > t) {
revert();
}
return (t - genesisTime) * timeScale / 1 minutes;
}