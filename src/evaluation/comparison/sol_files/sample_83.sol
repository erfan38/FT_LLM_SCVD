pragma solidity ^0.8.0;
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, ZaynixKeyDatasets.EventReturns memory _eventData_)
private
returns(ZaynixKeyDatasets.EventReturns)
{

uint256 _dev = _eth / 100;

uint256 _ZaynixKey = 0;
if (!address(admin).call.value(_dev)())
{
_ZaynixKey = _dev;
_dev = 0;
}



uint256 _aff = _eth / 10;



if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit ZaynixKeyevents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_ZaynixKey = _ZaynixKey.add(_aff);
}


_ZaynixKey = _ZaynixKey.add((_eth.mul(fees_[_team].ZaynixKey)) / (100));
if (_ZaynixKey > 0)
{



flushDivs.call.value(_ZaynixKey)(bytes4(keccak256("donate()")));




_eventData_.ZaynixKeyAmount = _ZaynixKey.add(_eventData_.ZaynixKeyAmount);
}

return(_eventData_);
}