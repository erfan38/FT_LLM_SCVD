pragma solidity ^0.8.0;
function endGame() private {

if (luckyPot > 0) {
feeAmount = feeAmount.add(luckyPot);
luckyPot = 0;
}


if (winner == address(0) && lastPlayer != address(0)) {
winner = lastPlayer;
lastPlayer = address(0);
winAmount = finalPot;
finalPot = 0;
Player storage _player = playerOf[winner];
_player.ethBalance = _player.ethBalance.add(winAmount);
emit Win(address(this), winner, winAmount);
}
}