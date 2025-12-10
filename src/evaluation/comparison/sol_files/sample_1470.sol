pragma solidity ^0.8.0;
function getGameInfo() public view returns (
uint256 _balance, uint256 _totalPot, uint256 _sharePot, uint256 _finalPot, uint256 _luckyPot, uint256 _rewardPot, uint256 _price,
uint256 _totalSupply, uint256 _now, uint256 _timeLeft, address _winner, uint256 _winAmount, uint8 _feePercent
) {
_balance = address(this).balance;
_totalPot = totalPot;
_sharePot = sharePot;
_finalPot = finalPot;
_luckyPot = luckyPot;
_rewardPot = _sharePot;
uint256 _withdraw = _sharePot.add(_finalPot).add(_luckyPot);
if (_totalPot > _withdraw) {
_rewardPot = _rewardPot.add(_totalPot.sub(_withdraw));
}
_price = price;
_totalSupply = totalSupply;
_now = now;
_feePercent = feeIndex >= feePercents.length ? 0 : feePercents[feeIndex];
if (now < finishTime) {
_timeLeft = finishTime - now;
} else {
_timeLeft = 0;
_winner = winner != address(0) ? winner : lastPlayer;
_winAmount = winner != address(0) ? winAmount : finalPot;
}
}