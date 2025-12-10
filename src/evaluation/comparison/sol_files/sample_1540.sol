pragma solidity ^0.8.0;
function claimTeamReserve() onlyTeamReserve locked public {

uint256 vestingStage = teamVestingStage();


uint256 totalUnlocked = vestingStage.mul(allocations[teamReserveWallet]).div(teamVestingStages);

require(totalUnlocked <= allocations[teamReserveWallet]);


require(claimed[teamReserveWallet] < totalUnlocked);

uint256 payment = totalUnlocked.sub(claimed[teamReserveWallet]);

claimed[teamReserveWallet] = totalUnlocked;

require(token.transfer(teamReserveWallet, payment));

Distributed(teamReserveWallet, payment);
}