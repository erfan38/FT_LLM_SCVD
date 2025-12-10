pragma solidity ^0.8.0;
function handlePot(uint256 _day, uint256 _eth, uint256 _newTotalSupply, uint256 _tokenAmount, Player storage _player, InternalBuyEvent memory _buyEvent) private {
uint256 _sharePotDelta = _eth.div(2);
uint256 _finalPotDelta = _eth.div(5);
uint256 _luckyPotDelta = _eth.mul(255).div(1000);
uint256 _dealerPotDelta = _eth.sub(_sharePotDelta).sub(_finalPotDelta).sub(_luckyPotDelta);
sharePot = sharePot.add(_sharePotDelta);
finalPot = finalPot.add(_finalPotDelta);
luckyPot = luckyPot.add(_luckyPotDelta);
totalSupply = _newTotalSupply;
handleDealerPot(_day, _dealerPotDelta, _player, _buyEvent);
handleLuckyPot(_eth, _player);

if (_tokenAmount >= ONE_TOKEN) {
updateFinishTime(_tokenAmount);
lastPlayer = msg.sender;
}
_buyEvent.flag1 += finishTime * 1000000000000000000000;
}