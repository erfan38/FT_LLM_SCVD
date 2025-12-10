pragma solidity ^0.8.0;
function changeOdd (uint64 _fixtureId, uint32 _odd_homeTeam, uint32 _odd_drawTeam, uint32 _odd_awayTeam, uint32 _odd_over, uint32 _odd_under, uint32 _odd_homeTeamAndDraw, uint32 _odd_homeAndAwayTeam , uint32 _odd_awayTeamAndDraw ) external onlyOwner {
gameList[_fixtureId].odd_homeTeam        = _odd_homeTeam;
gameList[_fixtureId].odd_drawTeam        = _odd_drawTeam;
gameList[_fixtureId].odd_awayTeam        = _odd_awayTeam;
gameList[_fixtureId].odd_over            = _odd_over;
gameList[_fixtureId].odd_under           = _odd_under;
gameList[_fixtureId].odd_homeTeamAndDraw = _odd_homeTeamAndDraw;
gameList[_fixtureId].odd_homeAndAwayTeam = _odd_homeAndAwayTeam;
gameList[_fixtureId].odd_awayTeamAndDraw = _odd_awayTeamAndDraw;
emit ChangeOdd (_fixtureId, _odd_homeTeam, _odd_drawTeam, _odd_awayTeam, _odd_over, _odd_under, _odd_homeTeamAndDraw, _odd_homeAndAwayTeam , _odd_awayTeamAndDraw);
}