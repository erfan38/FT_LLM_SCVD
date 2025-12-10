pragma solidity ^0.8.0;
function currentWeek() public view returns (uint week) {
return currentDay() / daysPerWeek;
}