pragma solidity ^0.8.0;
function handleLuckyReward(uint64 _txId, uint64 _level, uint256 _eth, Player storage _player) private {
uint256 _amount;
if (_level == 1) {
_amount = _eth.mul(7);
} else if (_level == 2) {
_amount = _eth.mul(3);
} else if (_level == 3) {
_amount = _eth;
} else if (_level == 4) {
_amount = _eth.div(2);
} else if (_level == 5) {
_amount = _eth.div(5);
} else if (_level == 6) {
_amount = _eth.div(10);
}
uint256 _maxPot = luckyPot.div(2);
if (_amount > _maxPot) {
_amount = _maxPot;
}
luckyPot = luckyPot.sub(_amount);
_player.ethBalance = _player.ethBalance.add(_amount);
LuckyRecord memory _record = LuckyRecord({
player: msg.sender,
amount: _amount,
txId: _txId,
level: _level,
time: uint64(now)
});
luckyRecords.push(_record);
}