pragma solidity ^0.8.0;
function teamVestingStage() public view onlyTeamReserve returns(uint256){


uint256 vestingMonths = teamTimeLock.div(teamVestingStages);

uint256 stage = (block.timestamp.sub(lockedAt)).div(vestingMonths);


if(stage > teamVestingStages){
stage = teamVestingStages;
}

return stage;

}