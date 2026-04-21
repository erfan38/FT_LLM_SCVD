pragma solidity ^0.8.0;
function() isActivated isAccount payable public {
uint256 _eth = msg.value;
require(now < finishTime);
InternalBuyEvent memory _buyEvent = InternalBuyEvent({
flag1: 0
});
Player storage _player = playerOf[msg.sender];
if (_player.pid == 0) {

require(_eth >= FEE_REGISTER_ACCOUNT);

uint256 _fee = FEE_REGISTER_ACCOUNT.sub(BUY_AMOUNT_MIN);
_eth = _eth.sub(_fee);

feeAmount = feeAmount.add(_fee);
playerCount = playerCount.add(1);
Player memory _p = Player({
pid: playerCount,
ethTotal: 0,
ethBalance: 0,
ethWithdraw: 0,
ethShareWithdraw: 0,
tokenBalance: 0,
tokenDay: 0,
tokenDayBalance: 0
});
playerOf[msg.sender] = _p;
playerIdOf[_p.pid] = msg.sender;
_player = playerOf[msg.sender];

_buyEvent.flag1 += 1;
}
buy(_player, _buyEvent, _eth);
}


function buy(Player storage _player, InternalBuyEvent memory _buyEvent, uint256 _amount) private {
require(now < finishTime && _amount >= BUY_AMOUNT_MIN && _amount <= BUY_AMOUNT_MAX);

uint256 _day = (now / 86400) * 86400;
uint256 _backEth = 0;
uint256 _eth = _amount;
if (totalPot < 200000000000000000000) {

if (_eth >= 5000000000000000000) {

_backEth = _eth.sub(5000000000000000000);
_eth = 5000000000000000000;
}
}
txCount = txCount + 1;
_buyEvent.flag1 += txCount * 10;
_player.ethTotal = _player.ethTotal.add(_eth);
totalPot = totalPot.add(_eth);

uint256 _newTotalSupply = calculateTotalSupply(totalPot);

uint256 _tokenAmount = _newTotalSupply.sub(totalSupply);
_player.tokenBalance = _player.tokenBalance.add(_tokenAmount);


if (_player.tokenDay == _day) {
_player.tokenDayBalance = _player.tokenDayBalance.add(_tokenAmount);
} else {
_player.tokenDay = _day;
_player.tokenDayBalance = _tokenAmount;
}

updatePrice(_newTotalSupply);
handlePot(_day, _eth, _newTotalSupply, _tokenAmount, _player, _buyEvent);
if (_backEth > 0) {
_player.ethBalance = _player.ethBalance.add(_backEth);
}
sendFeeIfAvailable();
emitEndTxEvents(_eth, _tokenAmount, _buyEvent);
}