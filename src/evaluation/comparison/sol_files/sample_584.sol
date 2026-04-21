pragma solidity ^0.8.0;
function initializeWeekData(uint _week) public {
if (dataPerWeek[_week].initialized) return;
WeekData storage week = dataPerWeek[_week];
week.initialized = true;
week.totalTokensCompleted = 0;
week.totalPeopleCompleted = 0;
week.totalTokens = 0;
week.totalPeople = 0;
week.totalDaysCommitted = 0;
week.totalDaysCompleted = 0;
}