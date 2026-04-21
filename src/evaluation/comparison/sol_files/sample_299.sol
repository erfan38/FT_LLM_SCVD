pragma solidity ^0.8.0;
function updateFinishTime(uint256 _tokenAmount) private {
uint256 _timeDelta = _tokenAmount.div(ONE_TOKEN).mul(TIME_DURATION_INCREASE);
uint256 _finishTime = finishTime.add(_timeDelta);
uint256 _maxTime = now.add(TIME_DURATION_MAX);
finishTime = _finishTime <= _maxTime ? _finishTime : _maxTime;
}