pragma solidity ^0.8.0;
function snapshotDailyGooResearchFunding() external onlyAdmin {
uint256 todaysGooResearchFund = (totalEtherPool[1] * researchDivPercent) / 100;
totalEtherPool[1] -= todaysGooResearchFund;

totalJadeProductionSnapshots.push(totalJadeProduction);
allocatedJadeResearchSnapshots.push(todaysGooResearchFund);
nextSnapshotTime = block.timestamp + 24 hours;
}