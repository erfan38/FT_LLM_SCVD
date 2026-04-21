pragma solidity ^0.8.0;
function updatePlayersCoinByPurchase(address player, uint256 purchaseCost) public onlyAccess {
uint256 unclaimedJade = balanceOfUnclaimed(player);

if (purchaseCost > unclaimedJade) {
uint256 jadeDecrease = SafeMath.sub(purchaseCost, unclaimedJade);
require(jadeBalance[player] >= jadeDecrease);
roughSupply = SafeMath.sub(roughSupply,jadeDecrease);
jadeBalance[player] = SafeMath.sub(jadeBalance[player],jadeDecrease);
} else {
uint256 jadeGain = SafeMath.sub(unclaimedJade,purchaseCost);
roughSupply = SafeMath.add(roughSupply,jadeGain);
jadeBalance[player] = SafeMath.add(jadeBalance[player],jadeGain);
}

lastJadeSaveTime[player] = block.timestamp;
}