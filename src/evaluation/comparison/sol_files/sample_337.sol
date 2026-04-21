pragma solidity ^0.8.0;
function currentTick() public view returns(uint) {
return whichTick(block.timestamp);
}