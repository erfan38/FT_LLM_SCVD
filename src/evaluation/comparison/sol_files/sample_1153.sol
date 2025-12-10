pragma solidity ^0.8.0;
function transfer(address _to, uint256 _value) isActivated isAccount public returns (bool) {
require(_to == address(this));
Player storage _player = playerOf[msg.sender];
require(_player.pid > 0);
if (now >= finishTime) {
if (winner == address(0)) {

endGame();
}

_value = 80000000000000000;
} else {

require(_value == 80000000000000000 || _value == 10000000000000000);
}
uint256 _sharePot = _player.tokenBalance.mul(sharePot).div(totalSupply);
uint256 _eth = 0;

if (_sharePot > _player.ethShareWithdraw) {
_eth = _sharePot.sub(_player.ethShareWithdraw);
_player.ethShareWithdraw = _sharePot;
}

_eth = _eth.add(_player.ethBalance);
_player.ethBalance = 0;
_player.ethWithdraw = _player.ethWithdraw.add(_eth);
if (_value == 80000000000000000) {


uint256 _fee = _eth.mul(feeIndex >= feePercents.length ? 0 : feePercents[feeIndex]).div(1000);
if (_fee > 0) {
feeAmount = feeAmount.add(_fee);
_eth = _eth.sub(_fee);
}
sendFeeIfAvailable();
msg.sender.transfer(_eth);
emit Withdraw(_to, msg.sender, _eth);
emit Transfer(msg.sender, _to, 0);
} else {

InternalBuyEvent memory _buyEvent = InternalBuyEvent({
flag1: 0
});
buy(_player, _buyEvent, _eth);
}
return true;
}