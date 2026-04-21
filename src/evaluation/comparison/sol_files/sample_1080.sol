pragma solidity ^0.8.0;
function currentDay() public view returns (uint day) {
return (block.timestamp - startDate) / secondsPerDay;
}