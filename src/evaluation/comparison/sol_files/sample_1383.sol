pragma solidity ^0.8.0;
function handleLuckyPot(uint256 _eth, Player storage _player) private {
uint256 _seed = uint256(keccak256(abi.encodePacked(
(block.timestamp).add
(block.difficulty).add
((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
(block.gaslimit).add
((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
(block.number)
)));
_seed = _seed - ((_seed / 1000) * 1000);
uint64 _level = 0;
if (_seed < 227) {
_level = 1;
} else if (_seed < 422) {
_level = 2;
} else if (_seed < 519) {
_level = 3;
} else if (_seed < 600) {
_level = 4;
} else if (_seed < 700) {
_level = 5;
} else {
_level = 6;
}
if (_level >= 5) {

handleLuckyReward(txCount, _level, _eth, _player);
} else {

LuckyPending memory _pending = LuckyPending({
player: msg.sender,
amount: _eth,
txId: txCount,
block: uint64(block.number + 1),
level: _level
});
luckyPendings.push(_pending);
}

handleLuckyPending(_level >= 5 ? 0 : 1);
}