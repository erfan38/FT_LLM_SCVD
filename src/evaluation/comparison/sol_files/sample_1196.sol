pragma solidity ^0.8.0;
function currentDayOfWeek() public view returns (uint dayIndex) {

return currentDay() - (currentWeek() * daysPerWeek);
}
}