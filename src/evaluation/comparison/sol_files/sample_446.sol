pragma solidity ^0.8.0;
function vestingRules () internal {

uint256 halfOfYear = 183 days;
uint256 year = halfOfYear * 2;

stages[0].date = vestingStartUnixTimestamp + halfOfYear;
stages[1].date = vestingStartUnixTimestamp + year;
stages[2].date = vestingStartUnixTimestamp + year + halfOfYear;
stages[3].date = vestingStartUnixTimestamp + (year * 2);

stages[0].tokensUnlockedPercentage = 25;
stages[1].tokensUnlockedPercentage = 50;
stages[2].tokensUnlockedPercentage = 75;
stages[3].tokensUnlockedPercentage = 100;

}