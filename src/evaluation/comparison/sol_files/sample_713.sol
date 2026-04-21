pragma solidity ^0.8.0;
function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
{

uint256 _rID = rID_;


uint256 _now = now;



if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
{

core(_rID, _pID, msg.value, _affID, _team, _eventData_);


} else {

if (_now > round_[_rID].end && round_[_rID].ended == false)
{

round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);


_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;


emit F3Devents.onBuyAndDistribute
(
msg.sender,
plyr_[_pID].name,
msg.value,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.P3DAmount,
_eventData_.genAmount
);
}


plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
}
}