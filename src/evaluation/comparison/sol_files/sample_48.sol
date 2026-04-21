pragma solidity ^0.8.0;
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, FFEIFDatasets.EventReturns memory _eventData_)
private
returns(FFEIFDatasets.EventReturns)
{
uint256 _PoEIF;


uint256 _aff = _eth.mul(affFee) / 100;



if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit FOMOEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_PoEIF = _aff;
}


_PoEIF = _PoEIF.add((_eth.mul(fees_[_team].poeif)) / 100);
if (_PoEIF > 0)
{

uint256 _EIFamount = _PoEIF / 2;

address(PoEIFContract).call.value(_PoEIF.sub(_EIFamount))(bytes4(keccak256("donateDivs()")));

fundEIF = fundEIF.add(_EIFamount);


_eventData_.tokenAmount = _PoEIF.add(_eventData_.tokenAmount);
}

return(_eventData_);
}