pragma solidity ^0.8.0;
function voteToHarvestFund() onlyTokenHolders noEther onlyLocked onlyFinalFiscalYear {

supportHarvestQuorum -= votedHarvest[msg.sender];
supportHarvestQuorum += balances[msg.sender];
votedHarvest[msg.sender] = balances[msg.sender];

uint threshold = ((tokensCreated + bountyTokensCreated) * harvestQuorumPercent) / 100;
if(supportHarvestQuorum > threshold) {
isHarvestEnabled = true;
evHarvest(msg.sender, msg.value);
}
}