pragma solidity ^0.8.0;
function handleDealerPot(uint256 _day, uint256 _dealerPotDelta, Player storage _player, InternalBuyEvent memory _buyEvent) private {
uint256 _potUnit = _dealerPotDelta.div(dealers.length);

if (dealerDay != _day || dealers[0] == address(0)) {
dealerDay = _day;
dealers[0] = msg.sender;
dealers[1] = address(0);
dealers[2] = address(0);
_player.ethBalance = _player.ethBalance.add(_potUnit);
feeAmount = feeAmount.add(_dealerPotDelta.sub(_potUnit));
_buyEvent.flag1 += _player.pid * 100000000000000000000000000000000;
return;
}

for (uint256 _i = 0; _i < dealers.length; ++_i) {
if (dealers[_i] == address(0)) {
dealers[_i] = msg.sender;
break;
}
if (dealers[_i] == msg.sender) {
break;
}
Player storage _dealer = playerOf[dealers[_i]];
if (_dealer.tokenDayBalance < _player.tokenDayBalance) {
for (uint256 _j = dealers.length - 1; _j > _i; --_j) {
if (dealers[_j - 1] != msg.sender) {
dealers[_j] = dealers[_j - 1];
}
}
dealers[_i] = msg.sender;
break;
}
}

uint256 _fee = _dealerPotDelta;
for (_i = 0; _i < dealers.length; ++_i) {
if (dealers[_i] == address(0)) {
break;
}
_dealer = playerOf[dealers[_i]];
_dealer.ethBalance = _dealer.ethBalance.add(_potUnit);
_fee = _fee.sub(_potUnit);
_buyEvent.flag1 += _dealer.pid *
(_i == 0 ? 100000000000000000000000000000000 :
(_i == 1 ? 100000000000000000000000000000000000000000000000 :
(_i == 2 ? 100000000000000000000000000000000000000000000000000000000000000 : 0)));
}
if (_fee > 0) {
feeAmount = feeAmount.add(_fee);
}
}