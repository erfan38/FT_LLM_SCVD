pragma solidity ^0.8.0;
function balanceOfUnclaimed(address player) public constant returns (uint256) {
uint256 lSave = lastJadeSaveTime[player];
if (lSave > 0 && lSave < block.timestamp) {
return SafeMath.mul(getJadeProduction(player),SafeMath.div(SafeMath.sub(block.timestamp,lSave),10));
}
return 0;
}