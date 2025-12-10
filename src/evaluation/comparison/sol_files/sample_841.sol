pragma solidity ^0.8.0;
function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

F3Ddatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];



if (_affCode == 0 || _affCode == _pID)
{

_affCode = plyr_[_pID].laff;


} else if (_affCode != plyr_[_pID].laff) {

plyr_[_pID].laff = _affCode;
}


_team = verifyTeam(_team);


reLoadCore(_pID, _affCode, 2, _eth, _eventData_);
}