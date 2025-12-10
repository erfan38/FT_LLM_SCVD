pragma solidity ^0.8.0;
function WithdrawICOEarnings() external
{
MinerData storage m = miners[msg.sender];

require(miners[msg.sender].lastUpdateTime != 0);
require(miners[msg.sender].lastPotClaimIndex < cycleCount);

uint256 i = m.lastPotClaimIndex;
uint256 limit = cycleCount;

if((limit - i) > 30)
limit = i + 30;

m.lastPotClaimIndex = limit;
for(; i < cycleCount; ++i)
{
if(minerICOPerCycle[msg.sender][i] > 0)
m.unclaimedPot += (honeyPotPerCycle[i] * minerICOPerCycle[msg.sender][i]) / globalICOPerCycle[i];
}
}