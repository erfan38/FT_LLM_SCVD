pragma solidity ^0.8.0;
function placeBet(uint64 _fixtureId, uint16 _selectedTeam, uint32 _odd) external payable  {
uint stake = msg.value;
require(stake >= .001 ether);
require(_odd != 0 );

if (_selectedTeam == 1 ) {
require(gameList[_fixtureId].odd_homeTeam == _odd);
} else if ( _selectedTeam == 2) {
require(gameList[_fixtureId].odd_drawTeam == _odd);
} else if ( _selectedTeam == 3) {
require(gameList[_fixtureId].odd_awayTeam == _odd);
} else if ( _selectedTeam == 4) {
require(gameList[_fixtureId].odd_over == _odd);
} else if ( _selectedTeam == 5) {
require(gameList[_fixtureId].odd_under == _odd);
} else if ( _selectedTeam == 6) {
require(gameList[_fixtureId].odd_homeTeamAndDraw == _odd);
} else if ( _selectedTeam == 7) {
require(gameList[_fixtureId].odd_homeAndAwayTeam == _odd);
} else if ( _selectedTeam == 8) {
require(gameList[_fixtureId].odd_awayTeamAndDraw == _odd);
} else {
revert();
}

require(gameList[_fixtureId].open_status == 3);
require( now < ( gameList[_fixtureId].timestamp  - 10 minutes ) );

betList[_fixtureId].push(BetFixture( msg.sender, stake,  _odd, _selectedTeam));
emit NewStake(msg.sender, _fixtureId, _selectedTeam, stake, _odd );

}