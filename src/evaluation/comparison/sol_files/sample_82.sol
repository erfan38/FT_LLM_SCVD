pragma solidity ^0.8.0;
struct WeekCommittment {
uint daysCompleted;
uint daysCommitted;
mapping(uint => uint) workoutProofs;
uint tokensCommitted;
uint tokensEarned;
bool tokensPaid;
}

struct WeekData {
bool initialized;
uint totalPeopleCompleted;
uint totalPeople;
uint totalDaysCommitted;
uint totalDaysCompleted;
uint totalTokensCompleted;
uint totalTokens;
}

uint public weiPerToken = 1000000000000000;
uint secondsPerDay = 86400;
uint daysPerWeek = 7;

mapping(uint => WeekData) public dataPerWeek;
mapping (address => mapping(uint => WeekCommittment)) public commitments;

mapping(uint => string) imageHashes;
uint imageHashCount;

uint public startDate;
address public owner;

constructor() public {
owner = msg.sender;

startDate = (block.timestamp / secondsPerDay) * secondsPerDay - 60 * 6;
}

event Log(string message);


function () public payable {
buyTokens(msg.value / weiPerToken);
}