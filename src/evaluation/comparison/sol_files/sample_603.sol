pragma solidity ^0.8.0;
function withdraw()
isActivated()
isHuman()
public
{

uint256 _rID = rID_;


uint256 _now = now;


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _eth;


if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
{

ZaynixKeyDatasets.EventReturns memory _eventData_;


round_[_rID].ended = true;
_eventData_ = endRound(_eventData_);


_eth = withdrawEarnings(_pID);


if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);


_eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;


emit ZaynixKeyevents.onWithdrawAndDistribute
(
msg.sender,
plyr_[_pID].name,
_eth,
_eventData_.compressedData,
_eventData_.compressedIDs,
_eventData_.winnerAddr,
_eventData_.winnerName,
_eventData_.amountWon,
_eventData_.newPot,
_eventData_.ZaynixKeyAmount,
_eventData_.genAmount
);


} else {

_eth = withdrawEarnings(_pID);


if (_eth > 0)
plyr_[_pID].addr.transfer(_eth);


emit ZaynixKeyevents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
}
}