pragma solidity ^0.8.0;
function handleLuckyPending(uint256 _pendingSkipSize) private {
if (luckyPendingIndex < luckyPendings.length - _pendingSkipSize) {
LuckyPending storage _pending = luckyPendings[luckyPendingIndex];
if (_pending.block <= block.number) {
uint256 _seed = uint256(keccak256(abi.encodePacked(
(block.timestamp).add
(block.difficulty).add
((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
(block.gaslimit).add
(block.number)
)));
_seed = _seed - ((_seed / 1000) * 1000);
handleLucyPendingForOne(_pending, _seed);
if (luckyPendingIndex < luckyPendings.length - _pendingSkipSize) {
_pending = luckyPendings[luckyPendingIndex];
if (_pending.block <= block.number) {
handleLucyPendingForOne(_pending, _seed);
}
}
}
}
}