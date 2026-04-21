pragma solidity ^0.8.0;
event cancelGame(
uint256 indexed gameId,
uint256 indexed barId,
uint256 amountReturned,
address playerAddress

);


function player_cancelGame(uint256 barId) public {
address _playerAddr = msg.sender;
uint256 _gameId = gameBars[barId].CurrentGameId;
uint256 _gamePlayerBalance = games[_gameId].PlayerBidMap[_playerAddr];

if(_gamePlayerBalance > 0){

games[_gameId].PlayerBidMap[_playerAddr] = 1;
games[_gameId].CurrentTotal -= _gamePlayerBalance;

if(!_playerAddr.send(_gamePlayerBalance)){

playerPendingWithdrawals[_playerAddr] = playerPendingWithdrawals[_playerAddr].add(_gamePlayerBalance);
}
}

emit cancelGame(
_gameId,
barId,
_gamePlayerBalance,
_playerAddr
);
}