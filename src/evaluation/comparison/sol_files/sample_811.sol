pragma solidity ^0.8.0;
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
{

uint256 _p1 = _eth / 50;
uint256 _com = _eth / 50;
_com = _com.add(_p1);

uint256 _p3d;
if (!address(admin).call.value(_com)())
{






_p3d = _com;
_com = 0;
}













uint256 _invest_return = 0;
_invest_return = distributeInvest(_pID, _eth, _affID);

_p3d = _p3d.add(_invest_return);


_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0)
{

uint256 _potAmount = _p3d / 2;

admin.transfer(_p3d.sub(_potAmount));

round_[_rID].pot = round_[_rID].pot.add(_potAmount);


_eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
}

return(_eventData_);
}