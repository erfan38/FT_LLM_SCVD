pragma solidity ^0.8.0;
function StartNewMiner() external
{
require(miners[msg.sender].lastUpdateTime == 0);

miners[msg.sender].lastUpdateTime = block.timestamp;
miners[msg.sender].money = 0;
miners[msg.sender].spaces[0] = 1;
miners[msg.sender].unclaimedPot = 0;
miners[msg.sender].lastPotClaimIndex = cycleCount;

pvpMap[msg.sender].immunityTime = block.timestamp + 14400;
pvpMap[msg.sender].exhaustTime  = block.timestamp;

indexes[topindex] = msg.sender;
++topindex;
}