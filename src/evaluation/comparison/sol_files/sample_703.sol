pragma solidity ^0.8.0;
function changeStakeTime(uint256 _newStakeTime) public onlyOwner{
stakeTime = _newStakeTime;
}