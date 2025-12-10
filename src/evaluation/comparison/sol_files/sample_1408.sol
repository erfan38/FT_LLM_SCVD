pragma solidity ^0.8.0;
function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
{

uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;


uint256 _air = (_eth / 100);
airDropPot_ = airDropPot_.add(_air);


_eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));


uint256 _pot = _eth.sub(_gen);



uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
if (_dust > 0)
_gen = _gen.sub(_dust);


round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);


_eventData_.genAmount = _gen.add(_eventData_.genAmount);
_eventData_.potAmount = _pot;

return(_eventData_);
}