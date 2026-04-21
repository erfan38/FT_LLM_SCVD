pragma solidity ^0.8.0;
function changeStakingPercentage(uint _newStakePercentage) public onlyOwner{
stakePercentage = _newStakePercentage;

}