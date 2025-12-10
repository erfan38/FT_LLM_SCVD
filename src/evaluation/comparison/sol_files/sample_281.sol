pragma solidity ^0.8.0;
function updatePlayersCoinByOut(address player) external onlyAccess {
uint256 coinGain = balanceOfUnclaimed(player);
lastJadeSaveTime[player] = block.timestamp;
roughSupply = SafeMath.add(roughSupply,coinGain);
jadeBalance[player] = SafeMath.add(jadeBalance[player],coinGain);
}