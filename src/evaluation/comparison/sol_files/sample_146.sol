pragma solidity ^0.8.0;
function givePrizeMoney(uint64 _fixtureId, uint8 _homeDrawAway, uint8 _overUnder) external onlyOwner payable {
require(gameList[_fixtureId].open_status == 3);
require(gameList[_fixtureId].isDone == false);
require(betList[_fixtureId][0].player != address(0) );

for (uint i= 0 ; i < betList[_fixtureId].length; i++){
uint16 selectedTeam = betList[_fixtureId][i].selectedTeam;
uint256 returnEth = (betList[_fixtureId][i].stake * betList[_fixtureId][i].odd) / 1000 ;
if ( (selectedTeam == 1 && _homeDrawAway == 1)
|| (selectedTeam == 2 && _homeDrawAway == 2)
|| (selectedTeam == 3 && _homeDrawAway == 3)
|| (selectedTeam == 4 && _overUnder == 1)
|| (selectedTeam == 5 && _overUnder == 2)
|| (selectedTeam == 6 && ( _homeDrawAway == 1 || _homeDrawAway == 2) )
|| (selectedTeam == 7 && ( _homeDrawAway == 1 || _homeDrawAway == 3) )
|| (selectedTeam == 8 && ( _homeDrawAway == 3 || _homeDrawAway == 2) )
){
betList[_fixtureId][i].player.transfer(returnEth);
}
}

gameList[_fixtureId].open_status = 5;
gameList[_fixtureId].isDone = true;

emit GivePrizeMoney( _fixtureId,  _homeDrawAway,  _overUnder);
}