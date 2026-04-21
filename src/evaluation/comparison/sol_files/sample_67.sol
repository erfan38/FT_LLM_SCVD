pragma solidity ^0.8.0;
function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, FFEIFDatasets.EventReturns memory _eventData_)
private
{

if (plyrRnds_[_pID][_rID].keys == 0)
_eventData_ = managePlayer(_pID, _eventData_);


if (round_[_rID].eth < earlyRoundLimitUntil && plyrRnds_[_pID][_rID].eth.add(_eth) > earlyRoundLimit)
{
uint256 _availableLimit = (earlyRoundLimit).sub(plyrRnds_[_pID][_rID].eth);
uint256 _refund = _eth.sub(_availableLimit);
plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
_eth = _availableLimit;
}


if (_eth > 1000000000)
{


uint256 _keys = keysRec(round_[_rID].eth,_eth);


bool newWinner = calcMult(_keys, multAllowLast==1 || round_[_rID].plyr != _pID);


if (_keys >= 1000000000000000000)
{
updateTimer(_keys, _rID);

if (newWinner) {

if (round_[_rID].plyr != _pID)
round_[_rID].plyr = _pID;
if (round_[_rID].team != _team)
round_[_rID].team = _team;


_eventData_.compressedData = _eventData_.compressedData + 100;
}
}


plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);


round_[_rID].keys = _keys.add(round_[_rID].keys);
round_[_rID].eth = _eth.add(round_[_rID].eth);
rndTmEth_[_rID][0] = _eth.add(rndTmEth_[_rID][0]);


_eventData_ = distributeExternal(_rID, _pID, _eth, _affID, 0, _eventData_);
_eventData_ = distributeInternal(_rID, _pID, _eth, 0, _keys, _eventData_);


endTx(_pID, 0, _eth, _keys, _eventData_);
}
}