pragma solidity ^0.8.0;
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, PCKdatasets.EventReturns memory _eventData_)
private
returns(PCKdatasets.EventReturns)
{

uint256 _com = _eth / 50;
uint256 _p3d;
if (!address(admin).call.value(_com)()) {






_p3d = _com;
_com = 0;
}


uint256 _long = _eth / 100;
potSwap(_long);


uint256 _aff = _eth / 10;



if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit PCKevents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_p3d = _aff;
}


_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0)
{
admin.transfer(_p3d.sub(_p3d / 2));

round_[_rID].pot = round_[_rID].pot.add(_p3d / 2);


_eventData_.PCPAmount = _p3d.add(_eventData_.PCPAmount);
}

return(_eventData_);
}