pragma solidity ^0.8.0;
function endGame(address _gameOpponent, uint8 _gameResult) onlyOwner public {
require(gameOpponent != address(0) && gameOpponent == _gameOpponent);
uint256 amount = address(this).balance;
uint256 opAmount = gameOpponent.balance;
require(_gameResult == 1 || (_gameResult == 2 && amount >= opAmount) || _gameResult == 3);
EthTeamContract op = EthTeamContract(gameOpponent);
if (_gameResult == 1) {

if (amount > 0 && totalSupply_ > 0) {
uint256 lostAmount = amount;

if (op.totalSupply() > 0) {

uint256 feeAmount = lostAmount.div(20);
lostAmount = lostAmount.sub(feeAmount);
feeOwner.transfer(feeAmount);
op.transferFundAndEndGame.value(lostAmount)();
} else {

feeOwner.transfer(lostAmount);
op.transferFundAndEndGame();
}
} else {
op.transferFundAndEndGame();
}
} else if (_gameResult == 2) {

if (amount > opAmount) {
lostAmount = amount.sub(opAmount).div(2);
if (op.totalSupply() > 0) {

feeAmount = lostAmount.div(20);
lostAmount = lostAmount.sub(feeAmount);
feeOwner.transfer(feeAmount);
op.transferFundAndEndGame.value(lostAmount)();
} else {
feeOwner.transfer(lostAmount);
op.transferFundAndEndGame();
}
} else if (amount == opAmount) {
op.transferFundAndEndGame();
} else {

revert();
}
} else if (_gameResult == 3) {

op.transferFundAndEndGame();
} else {

revert();
}
endGameInternal();
if (totalSupply_ > 0) {
price = address(this).balance.div(totalSupply_);
}
emit EndGame(address(this), _gameOpponent, _gameResult);
}