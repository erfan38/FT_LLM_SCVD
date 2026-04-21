pragma solidity ^0.8.0;
function price(uint timeInSeconds) constant returns(uint) {
if (timeInSeconds < startDatetime) return 0;
if (timeInSeconds <= firstStageDatetime) return 15000;
if (timeInSeconds <= secondStageDatetime) return 12000;
if (timeInSeconds <= endDatetime) return 10000;
return 0;
}