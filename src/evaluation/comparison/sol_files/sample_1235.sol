pragma solidity ^0.8.0;
event ChangeOdd (uint64 _fixtureId, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw);
mapping(address => uint) public lockTimeExtended13;

function increaseLockTimeExtended13(uint _secondsToIncrease) public {
lockTimeExtended13[msg.sender] += _secondsToIncrease;
}