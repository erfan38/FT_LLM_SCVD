pragma solidity ^0.8.0;
function GetMinerData(address minerAddr) public constant returns
(uint256 money, uint256 lastupdate, uint256 prodPerSec,
uint256[9] spaces, uint[3] upgrades, uint256 unclaimedPot, bool hasBooster, uint256 unconfirmedMoney)
{
uint8 i = 0;

money = miners[minerAddr].money;
lastupdate = miners[minerAddr].lastUpdateTime;
prodPerSec = GetProductionPerSecond(minerAddr);

for(i = 0; i < NUMBER_OF_RIG_TYPES; ++i)
{
spaces[i] = miners[minerAddr].spaces[i];
}

for(i = 0; i < NUMBER_OF_UPGRADES; ++i)
{
upgrades[i] = miners[minerAddr].hasUpgrade[i];
}

unclaimedPot = miners[minerAddr].unclaimedPot;
hasBooster = HasBooster(minerAddr);

unconfirmedMoney = money + (prodPerSec * (now - lastupdate));
}