pragma solidity ^0.8.0;
function reLoadXid(uint256 _affCode, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

FFEIFDatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];



if (_affCode == 0 || _affCode == _pID)
{

_affCode = plyr_[_pID].laff;


} else if (_affCode != plyr_[_pID].laff) {

plyr_[_pID].laff = _affCode;
}


reLoadCore(_pID, _affCode,  _eth, _eventData_);
}