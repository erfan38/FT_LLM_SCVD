pragma solidity ^0.8.0;
function GetPVPData(address addr) public constant returns (uint256 attackpower, uint256 defensepower, uint256 immunityTime, uint256 exhaustTime,
uint256[6] troops)
{
PVPData storage a = pvpMap[addr];

immunityTime = a.immunityTime;
exhaustTime = a.exhaustTime;

attackpower = 0;
defensepower = 0;
for(uint i = 0; i < NUMBER_OF_TROOPS; ++i)
{
attackpower  += a.troops[i] * troopData[i].attackPower;
defensepower += a.troops[i] * troopData[i].defensePower;

troops[i] = a.troops[i];
}
}