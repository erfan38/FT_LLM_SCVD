pragma solidity ^0.8.0;
function playGame(uint256 barId,
string _answer1, string _answer2, string _answer3) public
whenNotPaused
correctAnswers(barId, _answer1, _answer2, _answer3)
payable {
require(msg.value >= minGamePlayAmount);


uint256 houseAmt = (msg.value.div(100)).mul(houseEdge);
uint256 gameAmt = (msg.value.div(100)).mul(100-houseEdge);
uint256 currentGameId = 0;


if(gameBars[barId].CurrentGameId == 0) {

if(gameAmt > gameBars[barId].Limit) {
require(msg.value == minGamePlayAmount);
}

address[] memory _addressList;
games.push(Game(barId, gameAmt, _addressList));
currentGameId = games.length-1;

gameBars[barId].CurrentGameId = currentGameId;

} else {
currentGameId = gameBars[barId].CurrentGameId;
require(games[currentGameId].BarId > 0);
if(games[currentGameId].CurrentTotal.add(gameAmt) > gameBars[barId].Limit) {
require(msg.value == minGamePlayAmount);
}

games[currentGameId].CurrentTotal = games[currentGameId].CurrentTotal.add(gameAmt);
}



if(games[currentGameId].PlayerBidMap[msg.sender] == 0) {
games[currentGameId].PlayerAddressList.push(msg.sender);
}

games[currentGameId].PlayerBidMap[msg.sender] = games[currentGameId].PlayerBidMap[msg.sender].add(gameAmt);

bankBalance+=houseAmt;

if(games[currentGameId].CurrentTotal >= gameBars[barId].Limit) {

emit gameComplete(gameBars[barId].CurrentGameId);
gameBars[barId].CurrentGameId = 0;
}


}
event completeGameResult(
uint256 indexed gameId,
uint256 indexed barId,
uint256 winningNumber,
string  proof,
address winnersAddress,
uint256 winningAmount,
uint256 timestamp
);




function completeGame(uint256 gameId, uint256 _winningNumber, string _proof, address winner) public onlyOwner {



if(!winner.send(games[gameId].CurrentTotal)){

playerPendingWithdrawals[winner] = playerPendingWithdrawals[winner].add(games[gameId].CurrentTotal);
}


winners.push(Winner(
winner,
games[gameId].CurrentTotal,
now,
games[gameId].BarId,
gameId
));

emit completeGameResult(
gameId,
games[gameId].BarId,
_winningNumber,
_proof,
winner,
games[gameId].CurrentTotal,
now
);


gameBars[games[gameId].BarId].CurrentGameId = 0;



}