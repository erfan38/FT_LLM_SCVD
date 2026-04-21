pragma solidity ^0.8.0;
function GetMinerUnclaimedICOShare(address miner) public constant returns (uint256 unclaimedPot)
{
MinerData storage m = miners[miner];

require(m.lastUpdateTime != 0);
require(m.lastPotClaimIndex < cycleCount);

uint256 i = m.lastPotClaimIndex;
uint256 limit = cycleCount;

if((limit - i) > 30)
limit = i + 30;

unclaimedPot = 0;
for(; i < cycleCount; ++i)
{
if(minerICOPerCycle[miner][i] > 0)
unclaimedPot += (honeyPotPerCycle[i] * minerICOPerCycle[miner][i]) / globalICOPerCycle[i];
}
}