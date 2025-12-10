pragma solidity ^0.8.0;
function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
isActivated()
isHuman()
isWithinLimits(_eth)
public
{

F3Ddatasets.EventReturns memory _eventData_;


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _affID;

if (_affCode == '' || _affCode == plyr_[_pID].name)
{

_affID = plyr_[_pID].laff;


} else {

_affID = pIDxName_[_affCode];


if (_affID != plyr_[_pID].laff)
{

plyr_[_pID].laff = _affID;
}
}


_team = verifyTeam(_team);


reLoadCore(_pID, _affID, _team, _eth, _eventData_);
}