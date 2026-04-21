pragma solidity ^0.8.0;
function buyXaddr(address _affCode, uint256 _team)
isActivated()
isHuman()
isWithinLimits(msg.value)
public
payable
{

F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);


uint256 _pID = pIDxAddr_[msg.sender];


uint256 _affID;

if (_affCode == address(0) || _affCode == msg.sender)
{

_affID = plyr_[_pID].laff;


} else {

_affID = pIDxAddr_[_affCode];


if (_affID != plyr_[_pID].laff)
{

plyr_[_pID].laff = _affID;
}
}


_team = verifyTeam(_team);


buyCore(_pID, _affID, _team, _eventData_);
}