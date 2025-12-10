pragma solidity ^0.8.0;
function handleLucyPendingForOne(LuckyPending storage _pending, uint256 _seed) private {
luckyPendingIndex = luckyPendingIndex.add(1);
bool _reward = false;
if (_pending.level == 4) {
_reward = _seed < 617;
} else if (_pending.level == 3) {
_reward = _seed < 309;
} else if (_pending.level == 2) {
_reward = _seed < 102;
} else if (_pending.level == 1) {
_reward = _seed < 44;
}
if (_reward) {
handleLuckyReward(_pending.txId, _pending.level, _pending.amount, playerOf[_pending.player]);
}
}