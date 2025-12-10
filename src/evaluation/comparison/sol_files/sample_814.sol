pragma solidity ^0.8.0;
function Attack(address defenderAddr) external
{
require(msg.sender != defenderAddr);
require(miners[msg.sender].lastUpdateTime != 0);
require(miners[defenderAddr].lastUpdateTime != 0);

PVPData storage attacker = pvpMap[msg.sender];
PVPData storage defender = pvpMap[defenderAddr];
uint i = 0;
uint256 count = 0;

require(block.timestamp > attacker.exhaustTime);
require(block.timestamp > defender.immunityTime);


if(attacker.immunityTime > block.timestamp)
attacker.immunityTime = block.timestamp - 1;

attacker.exhaustTime = block.timestamp + 3600;

uint256 attackpower = 0;
uint256 defensepower = 0;
for(i = 0; i < ATTACKER_END_IDX; ++i)
{
attackpower  += attacker.troops[i] * troopData[i].attackPower;
defensepower += defender.troops[i + DEFENDER_START_IDX] * troopData[i + DEFENDER_START_IDX].defensePower;
}

if(attackpower > defensepower)
{
if(defender.immunityTime < block.timestamp + 14400)
defender.immunityTime = block.timestamp + 14400;

UpdateMoneyAt(defenderAddr);

MinerData storage m = miners[defenderAddr];
MinerData storage m2 = miners[msg.sender];
uint256 moneyStolen = m.money / 2;

for(i = DEFENDER_START_IDX; i < DEFENDER_END_IDX; ++i)
{
defender.troops[i] = defender.troops[i]/2;
}

for(i = ATTACKER_START_IDX; i < ATTACKER_END_IDX; ++i)
{
if(troopData[i].attackPower > 0)
{
count = attacker.troops[i];


if((count * troopData[i].attackPower) > defensepower)
{
count = count * defensepower / attackpower / 2;
}
else
{
count =  count/2;
}
attacker.troops[i] = SafeMath.sub(attacker.troops[i],count);
defensepower -= count * troopData[i].attackPower;
}
}

m.money -= moneyStolen;
m2.money += moneyStolen;
} else
{
for(i = ATTACKER_START_IDX; i < ATTACKER_END_IDX; ++i)
{
attacker.troops[i] = attacker.troops[i] / 2;
}

for(i = DEFENDER_START_IDX; i < DEFENDER_END_IDX; ++i)
{
if(troopData[i].defensePower > 0)
{
count = defender.troops[i];


if((count * troopData[i].defensePower) > attackpower)
count = count * attackpower / defensepower / 2;

defender.troops[i] -= count;
attackpower -= count * troopData[i].defensePower;
}
}
}
}