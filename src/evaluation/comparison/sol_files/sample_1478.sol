pragma solidity ^0.8.0;
function modifyNextCap (uint time, uint cap) public onlyOwner {
require (contractStage == 1);
require (contributionCap <= cap && maxContractBalance >= cap);
require (time > now);
nextCapTime = time;
nextContributionCap = cap;
}